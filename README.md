# dartmon

A simple tool that helps to develop dart applications. It watches on the project directory, and restarts the application whenever any change is detected.

> Inspired by [nodemon](https://github.com/remy/nodemon) on nodejs and [dartman](https://github.com/loicnestler/dartman) on dart

### Installation
```yaml
dev_dependencies:
  dartmon:
    git: https://github.com/Akash98Sky/dartmon.git
```

### Usage
```bash
pub run dartmon example/main.dart Dartmon
```

### With [derry](https://pub.dev/packages/derry)
* Install derry from [pub.dev](https://pub.dev/packages/derry)
* Add scripts to pubspec.yaml
  ```yaml
  scripts:
    dev: pub run dartmon example/main.dart Dartmon
  ```
* Run script from command-line
  ```bash
  derry dev
  ```

### License
MIT © 2021 Akash Mondal