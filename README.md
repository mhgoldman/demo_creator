# Demo Creator

## Introduction
This sample app enables easy provisioning of Skytap environments for sales demo use cases. It provides a streamlined interface for nontechnical salespeople who are not familiar with Skytap to request and access sales demo environments, while enabling the administrator to limit access to authorized users and keep usage in check.

## Features
- A salesperson can request demo environments by accessing a simple web form, selecting the desired template, providing his company email address, and entering an optional comment. A confirmation link is emailed to the user, and once clicked, the environment is immediately provisioned.
- A simple email domain whitelist limits access to company employees and helps to preserve the customer's account quota.
- End user don't need Skytap accounts or user credentials of any kind. All access to the provisioned environments is provided through published URLs.
- Demo environments can be provisioned from any template in the designated project containing a single published URL. The list of available templates is pulled in automatically and can be updated periodically via a cron job.
- Schedules are used to automatically delete each demo environment after the designated period of time has elapsed.
- Demo environments are owned by special "shadow" user accounts that are mapped 1-1 with requestor email addresses. These shadow users are automatically created on the fly and can be added to a specially designated department as well. This allows quotas to be applied on the number of demo environments in existence, both on a per-email address basis and on an application-wide basis.
- Each demo environment's network can optionally be connected to a "global network" in the Skytap account via ICNR for access to global resources such as licensing servers.

## Requirements
- Ruby 2.2
- Rails 4.2
- PostgreSQL database - SQLite is not supported, as the application depends on the Que job queue which has a dependency on Postgres specifically.

## Getting started
If you don't know how to install Rails and happen to be installing on a Skytap Ubuntu 14.04 VM, there is a _very_ quick-and-dirty installation script you could try in the root of the git repo. Otherwise, here is a high-level summary of what you need to do.

- Install Ruby, Rails and Postgres if you don't have them. 
- Ensure you have the Bundler gem installed: `gem install bundler`
- In the root of your checked-out repo:

```
#!bash

bundle install
rake db:create
rake db:migrate
```
- Create a configuration file in `config/application.yml` using the sample in `config/application.yml.example` as a guide.
- To load the list of available templates, run `rails r Template.pull`. If this fails, double check your config file.
- Optionally, configure your crontab to update the list of available templates on an hourly basis: `whenever --set environment=development -w`
- Start the server: `rails s -b 0.0.0.0`