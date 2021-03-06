namespace: tutorials.hiring

imports:
  base: tutorials.base
  hire: tutorials.hiring

flow:
  name: hire_all

  inputs:
    - names_list

  workflow:
    - process_all:
        parallel_loop:
          for: name in eval(names_list)
          do:
            hire.new_hire:
              - first_name: ${name["first"]}
              - middle_name: ${name.get("middle","")}
              - last_name: ${name["last"]}
        publish:
          - email_list: "${', '.join(filter(lambda x : x != '', map(lambda x : str(x['address']), branches_context)))}"
          - cost: "${str(sum(map(lambda x : int(x['final_cost']), branches_context)))}"
        navigate:
          - SUCCESS: print_success
          - FAILURE: print_failure

    - print_success:
        do:
          base.print:
            - text: >
                ${"All addresses were created successfully.\n" + 
                "Email addresses created: " + email_list + "\n" +
                "Total cost: $" + cost}
        navigate:
        - SUCCESS: SUCCESS

    - on_failure:
        - print_failure:
            do:
              base.print:
                - text: >
                    ${"Some addresses were not created or there is an email issue.\n" +
                    "Email addresses created: " + email_list + "\n" +
                    "Total cost: $" + cost}