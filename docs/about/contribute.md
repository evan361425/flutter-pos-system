# Contributing to the POS System

Hello everyone! We're thrilled that you're interested in helping improve the POS system. Your contributions will make this application even better!

This POS system is an open-source project, built bit by bit by various contributors. We're excited to have you join us. Regardless of how much time or skill you can offer, we deeply appreciate your contributions. There are many ways to contribute:

- [Improve Documentation](#improve-documentation)
- [Report Bugs](#how-to-report-bugs)
- [Propose New Features or Enhancements](#propose-new-features-or-enhancements)
- [Design and Interface Improvements](#adjust-the-user-interface)
- Respond to other people's [issues](https://github.com/evan361425/flutter-pos-system/issues)
- [Directly Write Code to Improve the POS System](#how-to-submit-code-changes)

Following the guidelines below will accelerate the development process. We also provide assistance, such as verifying issues, confirming improvements, and helping finalize pull requests (PRs).

> What is a [PR](https://gitbook.tw/chapters/github/pull-request.html)?

## Need Any Help?

If you encounter any issues not covered in this document, feel free to [email us](mailto:evanlu361425@gmail.com).
Alternatively, you can [open an issue](https://github.com/evan361425/flutter-pos-system/issues/new) to ask your question. Others might have the same question, and we can solve it together 😬.

## Improve Documentation

If you find the documentation unclear or awkward while reading it, it likely needs improvement. First, check if there are any [related issues](https://github.com/evan361425/flutter-pos-system/labels/document).
If not, please [submit a related issue](https://github.com/evan361425/flutter-pos-system/issues/new?assignees=&labels=&template=document.md&title=).

In addition, consider improving the documentation if you:

- Find typos.
- Think additional diagrams could help with understanding.
- Want to add supplementary documents or external links.
- Add new features and need to update the relevant documentation.
- Can't find information where you'd expect it, indicating the need to add it there.

When making [code changes](#how-to-submit-code-changes), remember to switch the main branch to `gh-pages` before creating a new branch with `git checkout -b my-branch-name`. Run `git checkout gh-pages` before the above command. When merging, select `gh-pages` as the base branch.

## How to Report Bugs

Found a bug? First, check if it has [already been reported](https://github.com/evan361425/flutter-pos-system/labels/bug). If not, please [submit a related issue](https://github.com/evan361425/flutter-pos-system/issues/new?assignees=&labels=&template=bug_report.md&title=).

Here are some tips for writing a good bug report:

- Clearly describe the issue (e.g., "error occurs" vs. "creating a product menu allows identical names to be set successfully").
- Explain how you encountered the issue.
- State the expected outcome versus the actual result.
- Ensure you're using the latest version of the app.
- Specify your device model and OS version.
- Report one bug per issue; submit separate issues for multiple bugs.
- Even if you don't know how to fix the issue, helping others reproduce it can speed up resolution.
- For security issues, do not open an issue. Instead, email <evanlu361425@gmail.com> for specialized handling.

## Propose New Features or Enhancements

If you have an idea for a feature that the POS system lacks, you're likely not alone. Many features have been added based on user feedback.

We welcome new feature proposals. Ensure the feature relates to the POS system and provide enough detail and feasibility. Explain the problem the feature aims to solve.

Thank you for helping improve the product. Start [creating a related issue](https://github.com/evan361425/flutter-pos-system/issues/new?assignees=&labels=&template=feature_request.md&title=)!

## Adjust the User Interface

A good application needs a well-designed user interface, including both aesthetics and user experience. If you think a particular section needs a color change, let's try it! Please submit a [related issue](https://github.com/evan361425/flutter-pos-system/issues/new?assignees=&labels=&template=design.md&title=).

Consider the following:

- Design changes are subjective; user support (e.g., likes) may be required for consideration.
- Provide before-and-after screenshots to aid the PR process.
- Set colors in constants rather than component-specific variables.

## First-Time Contribution

We're delighted you want to contribute. If you're unsure where to start, check the [good first issue](https://github.com/evan361425/flutter-pos-system/issues?q=is%3Aissue+label%3A%22good+first+issue%22) label for suitable issues. Also, the [help wanted](https://github.com/evan361425/flutter-pos-system/issues?q=is%3Aissue+label%3A%22help+wanted%22) label is a good place to find tasks needing assistance.

- Good first issues usually involve minor code changes and a unit test.
- Help wanted issues might require more skill and experience but are areas needing help.

> Feel free to ask questions via issue or email. Everyone starts as a beginner 😺.

## How to Submit Code Changes

Here are some guidelines for submitting code changes:

- For UI changes, provide before-and-after screenshots.
- Follow the Flutter code [style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo).
- Update relevant documentation for any user-facing changes.
- Each PR should address one feature or bug. Submit separate PRs for multiple changes.
- Avoid modifying unrelated files.
- [Write good commit messages](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).

Steps for code changes:

- [Fork](https://github.com/evan361425/flutter-pos-system/fork) and clone the project.
- Install necessary dependencies: `flutter pub get`.
- Install helper tools: `flutter run build_runner build`.
- Ensure local tests pass: `flutter test`.
- Create a new branch: `git checkout -b my-branch-name`.
- Make your changes and add tests.
- Push to your fork and submit a PR: `git push -u origin my-branch-name`.
- Take a break 😆. Someone will review and merge your PR.

Excited to submit your first PR? Check out GitHub's [How to Contribute to Open Source](https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github) guide.

## How to Set Up the Local Environment

See [Local Development](../maintenance/development.md).

## How to Run Tests

See [Local Development](../maintenance/development.md).

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](../CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Additional Resources

- [Contributing to Open Source on GitHub](https://guides.github.com/activities/contributing-to-open-source/)
- [Using Pull Requests](https://help.github.com/articles/using-pull-requests/)
- [GitHub Help](https://help.github.com)
