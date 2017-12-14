namespace: tutorials.hiring

operation:
  name: check_availability

  inputs:
    - address
    
  python_action:
    script: |
        import random
        import string
        rand = random.randint(0, 2)
        vacant = rand != 0
        #print rand
        if vacant:
            password = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(6))
        else:
            password = ''

  outputs:
    - available: ${str(vacant)}
    - password:
        value: ${password}
        sensitive: True

  results:
    - UNAVAILABLE: ${rand == 0}
    - AVAILABLE