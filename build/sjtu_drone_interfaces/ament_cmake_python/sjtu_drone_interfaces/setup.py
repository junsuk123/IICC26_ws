from setuptools import find_packages
from setuptools import setup

setup(
    name='sjtu_drone_interfaces',
    version='0.0.0',
    packages=find_packages(
        include=('sjtu_drone_interfaces', 'sjtu_drone_interfaces.*')),
)
