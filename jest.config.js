module.exports = {
  testEnvironment: 'node',
  testMatch: ['<rootDir>/spec/javascripts/**/*.test.js'],
  rootDir: '.',
  reporters: [
    'default',
    ['jest-junit', { outputDirectory: 'tmp/test', outputName: 'jest.xml' }]
  ]
};
