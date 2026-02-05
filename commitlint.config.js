// ABOUTME: Commitlint configuration for conventional commit enforcement.
// ABOUTME: Validates commit messages follow the conventional commits format.

module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',
        'fix',
        'refactor',
        'docs',
        'test',
        'chore',
        'style',
        'perf',
        'ci',
        'build',
        'revert',
      ],
    ],
    'subject-max-length': [2, 'always', 100],
    'body-max-line-length': [1, 'always', 120],
  },
};
