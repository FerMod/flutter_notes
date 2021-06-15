> **WIP document**

# Contributing

First off, thank you for considering contributing to this project!

The following is a set of guidelines for contributing, which are hosted on GitHub. These are mostly guidelines, not rules.

Following these guidelines helps to communicate that you respect the time of the developers managing and developing this open source project.
In return, they should reciprocate that respect in addressing your issue, assessing changes, and helping you finalize your pull requests.

By improving documentation, writing tutorials, submitting bug reports and feature requests or writing code which can be incorporated into the project, etc. all examples of helpful contributions that could help and are very welcome.
Use your best judgment, and feel free to propose changes to this document in a pull request.

## Ground Rules

### Responsibilities

- Ensure for every change that's accepted, cross-platform compatibility of the project supported platforms.
- Ensure that code that goes into core meets a minimum requirements.
- Create issues for any major changes and enhancements that you wish to make. Discuss things transparently and get community feedback.
- Be welcoming to newcomers and encourage diverse new contributors from all backgrounds. See the [Code of Conduct](CODE_OF_CONDUCT.md).

## Your First Contribution

### Unsure where to begin contributing?

You can start by looking through [help wanted](../../labels/help%20wanted) issues.

### Working on your first Pull Request?

You can learn how from this *free* series, [How to Contribute to an Open Source Project on GitHub](https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github).

Feel free to ask for help, everyone is a beginner at first.
If a maintainer asks you to "rebase" your PR, they're saying that a lot of code has changed, and that you need to update your branch so it's easier to merge.

## Getting started

### Prerequisites

This project requires to have **Flutter** installed.

### Cloning/Forking the repository

To start contributing to this project you need first to clone the project or fork the project. To clone the project, the command is the following:

```bash
git clone https://github.com/FerMod/flutter_notes.git
```

After the project is cloned, change to the project folder and create your branch and start developing.

## How to report a bug

The project have issue templates to help to provide all the required information. Try to fill the requested information as it could help and shorten the time to fix the issue.

If you find a security vulnerability, do **NOT** open an issue. Email the project owner instead.

## How to suggest a feature or enhancement

If you find yourself wishing for a feature that doesn't exist in, you are probably not alone and there are high chances that there are others with similar needs. Open an issue on which describes the feature you would like to see, why you need it, and how it should work. But you should check first, if there is already one created.
There is a template that helps to suggest features or enhancements, use it if it helps you.

When referencing commits, issues, pull request, etc. try tu use [autolinked references](https://help.github.com/en/articles/autolinked-references-and-urls).

## Code review process

The Pull Request are looked on a regular basis and it will be accepted and incorpored to the project as soon as posible, if the changes are thought to bee good enough.

## Styleguides

### Git Commit Messages

As a general rule, the style and formatting of commit messages should follow the guidelines in [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/).

#### Use the imperative tense

When displayed on the web, it's often styled as a heading, and in emails, it's typically used as the subject. As such, you should capitalize it and omit any trailing punctuation. Consistent wording makes it easier to mentally process a list of commits.

Examples:  
`Add feature` not ~~`Added feature`~~  
`Fix bug` not ~~`Fixed bug`~~ or ~~`Fixes bug`~~

#### Limit the first line to 72 characters or less

The first line of a commit message serves as a summary, it should be concise to ensure that they are readable. When it's not, add a blank line (this is important) followed by the rest of the commit message.

The best line length should be of 50 characterers or less, and the 72 characters should be treated as a hard limit.

#### Issue References

When refering to issues and pull requests you should reference them in the commit.

Any commit that is related to an existing issue should reference the issue. For example, if a commit in a pull request addresses issue #123, it should contain the following at the bottom of the commit message.

```diff
Issue #123
```

Or if the commit references more than one issue:

```diff
Issue #123, #124
```

If the commit closes the issue it should be referenced using one of the available keywords that automates the issue closing once the branch merges with the default branch.

```diff
Add feature

Description in more detail of the commit if needed.
With synxtax like '#123' references issues and pull request and with 'close #123', can automatically close them.

Fixes #123
```

For more info about wich words close issues read [Closing Issues Using Keywords](https://help.github.com/en/articles/closing-issues-using-keywords).

### Use of labels in issues and pull request

The use of labels in issues and pull request is not a requeriment but a suggestion that certainly helps the filtering and sorting.
These are the [current project labels](../../labels).
