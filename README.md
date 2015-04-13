# DeclarativeUI

## Background
MVC as Massive View Controller. Navigation logic scattered around Storyboard, prepareForSegue: and "plain code" approach.

## Goal
Implement router module with following features:

- Provide a way to describe navigation flow programmatically.
- Such description should not be placed all over the UI implementation.
- Type safe.
- Way to bind View Model to View.
- Move decision about when and where transitions shold occur to View Models.

## Benefits
View layer (View + UIViewController) no more contains "semi-UI semi-Model" logic. Easier to write functional tests.
