import sys
if sys.prefix == '/usr':
    sys.real_prefix = sys.prefix
    sys.prefix = sys.exec_prefix = '/home/j/INCSL/IICC26_ws/install/sjtu_drone_control'
