namespace: tutorials.base

operation:
  name: fancy_text

  inputs:
    - text

  python_action:
    script: |
      from pyfiglet import Figlet
      f = Figlet(font='slant')
      fancy = f.renderText(text)
      
  outputs:
    - fancy