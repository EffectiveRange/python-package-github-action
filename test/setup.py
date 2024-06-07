import platform

from setuptools import setup


def get_platform_name() -> str:
    return platform.system().lower() + '-' + platform.machine().lower()


setup(
    name='test-module',
    version='1.0.0',
    options={
        "bdist_wheel": {
            "plat_name": get_platform_name(),
        },
    },
    description='Test module for packaging',
    author='Global Scope Ltd.',
    author_email='info@globalscope.info',
    packages=['main']
)
