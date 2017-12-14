namespace: tutorials.hiring

imports:
  base: tutorials.base
  hire: tutorials.hiring
  mail: io.cloudslang.base.mail

flow:
  name: new_hire

  inputs:
  - first_name
  - middle_name:
      required: false
  - last_name
  - all_missing:
      default: ""
      required: false
      private: true
  - total_cost:
      default: '0'
      private: true
  - order_map:
      default: '{"laptop": 1000, "docking station": 200, "monitor": 500, "phone": 100}'

  workflow:
    - print_start:
        do:
          base.print:
            - text: "Starting new hire process"
        navigate:
          - SUCCESS: create_email_address

    - create_email_address:
        loop:
          for: attempt in [1,2,3,4]
          do:
            hire.create_user_email:
              - first_name
              - middle_name
              - last_name
              - attempt: ${str(attempt)}
          publish:
            - address
            - password
          break:
            - CREATED
            - FAILURE
          navigate:
          - CREATED: get_equipment
          - UNAVAILABLE: print_fail
          - FAILURE: print_fail
    
    - get_equipment:
        loop:
          for: item, price in eval(order_map)
          do:
            hire.order:
              - item
              - price: ${str(price)}
              - missing: ${all_missing}
              - cost: ${total_cost}
          break: []
          publish:
            - all_missing: ${missing + not_ordered}
            - total_cost: ${str(int(cost) + int(spent))}
          navigate:
          - AVAILABLE: check_min_reqs
          - UNAVAILABLE: check_min_reqs

    - check_min_reqs:
        do:
          base.contains:
            - container: ${all_missing}
            - sub: 'laptop'
        navigate:
          - DOES_NOT_CONTAIN: fancy_name
          - CONTAINS: print_warning

    - print_warning:
        do:
          base.print:
            - text: >
                ${first_name + ' ' + last_name +
                ' did not receive all the required equipment'}
        navigate:
          - SUCCESS: fancy_name

    - fancy_name:
        do:
          base.fancy_text:
            - text: ${first_name + ' ' + last_name}
        publish:
          - fancy_text: ${fancy}
        navigate:
          - SUCCESS: print_finish

    - print_finish:
        do:
          base.print:
            - text: >
                ${'\n' + fancy_text + '\n' +
                'Email: ' + address + '\n' +
                'Missing items: ' + all_missing + '\n' +
                'Cost of ordered items: $' + total_cost}
        publish:
          - message: ${'<pre>' + text.replace('\n','<br>').replace(' ', '&nbsp') + '<pre>'}
        navigate:
          - SUCCESS: send_mail

    - send_mail:
        do:
          mail.send_mail:
            - hostname: ${get_sp('tutorials.properties.hostname')}
            - port: ${get_sp('tutorials.properties.port')}
            - username: ${get_sp('tutorials.properties.system_address')}
            - password: ${get_sp('tutorials.properties.password')}
            - enable_TLS: "True"
            - from: ${username}
            - to: ${get_sp('tutorials.properties.hr_address')}
            - subject: "${'New Hire: ' + first_name + ' ' + last_name}"
            - body: ${message}
            - html_email: "True"
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: SUCCESS

    - on_failure:
      - print_fail:
          do:
            base.print:
              - text: "${'Failed to create address for: ' + first_name + ' ' + last_name}"

  outputs:
  - address
  - final_cost: ${total_cost}