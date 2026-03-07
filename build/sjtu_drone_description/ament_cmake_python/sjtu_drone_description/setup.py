from setuptools import find_packages
from setuptools import setup

setup(
    name='sjtu_drone_description',
    version='0.0.0',
    packages=find_packages(
        include=('sjtu_drone_description', 'sjtu_drone_description.*')),
)
