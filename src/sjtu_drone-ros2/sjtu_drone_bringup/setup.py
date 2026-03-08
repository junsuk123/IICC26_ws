from setuptools import setup
from glob import glob
import os
import sys

# colcon may pass args that older distutils parsers don't recognize.
# Strip unsupported args while preserving normal setup.py invocation.
def _sanitize_argv(argv):
    cleaned = [argv[0]]
    skip_next = False
    for arg in argv[1:]:
        if skip_next:
            skip_next = False
            continue
        if arg in ('--editable', '--uninstall'):
            continue
        if arg == '--build-directory':
            skip_next = True
            continue
        cleaned.append(arg)
    return cleaned


sys.argv = _sanitize_argv(sys.argv)

package_name = 'sjtu_drone_bringup'

setup(
    name=package_name,
    version='0.0.0',
    packages=[package_name],
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
        (os.path.join('share', package_name, "launch"), glob('launch/*launch.[pxy][yma]*')),
        (os.path.join('share', package_name, "rviz"), glob('rviz/*.rviz')),
        (os.path.join('share', package_name, "config"), glob('config/*.yaml')),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='ubuntu',
    maintainer_email='georg.novtony@aon.at',
    description='TODO: Package description',
    license='TODO: License declaration',
    entry_points={
        'console_scripts': [
            'spawn_drone = sjtu_drone_bringup.spawn_drone:main',
            'apriltag_state_bridge = sjtu_drone_bringup.apriltag_state_bridge:main',
        ],
    },
)
