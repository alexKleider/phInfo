# Ubuntu instructions

## Quickstart

You can run this automated script on Ubuntu 16.04.

    curl 'https://raw.githubusercontent.com/alexKleider/phInfo/master/bootstrap.sh' | bash -s

And that's it!

If you're running on a different version of Ubuntu, or you'd prefer to have more
control over the configuration, then follow the Setup instructions below.


## Setup

Pathagar is a [Django](https://www.djangoproject.com/) web application. If you
are familiar with setting up Django, this should be familiar to you. There are
[many](https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu-14-04)
[detailed](https://www.digitalocean.com/community/tutorials/how-to-use-postgresql-with-your-django-application-on-ubuntu-14-04)
[guides](https://docs.djangoproject.com/en/1.11/howto/deployment/wsgi/modwsgi/)
on the internet.

1. Install a database (e.g. postgresql or mysql)
1. Install a web server (e.g. nginx or apache)
1. Un-tar the [latest version](https://github.com/PathagarBooks/pathagar/releases) of Pathagar.
1. Install the python dependencies in your virtual environment
1. Configure Pathagar by editing your `local_settings.py`
1. Run the Django setup (python manage.py collectstatic)
1. Create a database and configure your web server


## Development

If you are testing the bootstrap script with another repository, you can pass it
parameters, e.g.

    curl 'https://raw.githubusercontent.com/alexKleider/phInfo/master/bootstrap.sh' | bash -s <username/repo> <branch>
