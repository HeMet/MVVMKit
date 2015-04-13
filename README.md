# DeclarativeUI

## Background
MVC as Massive View Controller. Navigation logic scattered around Storyboard, prepareForSegue: and "plain code" approach.

## Goal
Implement router module with following features:
1. Provide a way to describe navigation flow programmatically.
2. Such description should not be placed all over the UI implementation.
3. Type safe.
4. Way to bind View Model to View.
5. Move decision about when and where transitions shold occur to View Models.

## Benefits
View layer (View + UIViewController) no more contains "semi-UI semi-Model" logic. Easier to write functional tests.
