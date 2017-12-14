namespace: tutorials.hiring

operation:
  name: generate_user_email

  inputs:
    - first_name
    - middle_name:
        required: false
        default: ""
    - last_name
    - domain:
        default: ${get_sp('tutorials.properties.domain', 'somecompany.com')}
        private: true
    - attempt 

  python_action:
    script: |
        attempt = int(attempt)
        if attempt == 1:
            address = first_name + '.' + last_name + '@' + domain
            address = address.lower()
        elif attempt == 2:
            address = first_name[0:1] + '.' + last_name + '@' + domain
            address = address.lower()
        elif attempt == 3 and middle_name != '':
            address = first_name + '.' + middle_name[0:1] + '.' + last_name + '@' + domain
            address = address.lower()
        else:
            address = ''
        print ' - Address created!'

  outputs:
    - email_address: ${address}

  results:
    - FAILURE: ${address == ''}
    - SUCCESS