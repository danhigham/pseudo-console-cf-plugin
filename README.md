### support-cf-plugin

At the moment this is just in testing, but if you want to use it;

1. Clone the repo

```
$ git clone https://github.com/danhigham/support-cf-plugin.git
```

2. Create a gemfile

```
$ cd support-cf-plugin
$ gem build support-cf-plugin.gemspec
```

3. Install the gem

```
$ gem install support-cf-plugin-0.0.1.gem
```

To send logs to run.pivotal.io support, do;

```
$ cf send-logs [application name]
```