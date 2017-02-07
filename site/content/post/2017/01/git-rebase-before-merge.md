+++
categories = ["git"]
date = "2017-01-18T11:21:11+01:00"
title = "Rebasing a branch before doing the real merge"
+++

When working on a branch with tools like GitLab, I can then easily create
a _merge request_ and merge the branch back into master using a GUI.
However, this happy path is only available if there is no conflict between
the development branch and master.

So what should the process look like? This has been taken from a post
on [StackOverflow](http://stackoverflow.com/questions/23748973/is-it-neccessary-to-update-git-branch-before-merging-it-to-develop-master)
and adapted for my use case, as a reference for my _furure self_:

1. git checkout master
2. git pull
3. git checkout _issue/123-blah_
4. git rebase master
5. ...fix any conflicts...
6. git pull
7. ...fix any conflicts...
8. git push
9. accept the merge request

## Fix conflicts while rebasing

The `git rebase` command is quite helpful and provides guidance about the
steps which need to be taken. The step **5** above can be described as:

* Open the _Git panel_ in Visual Studio Code (Ctrl+Shift+G).
* Edit the files which need our attention; usually, this means choosing
  between two conflicting sections identified by `<<<` ... `===` ... `>>>`
  markers (known as [conflict markers](http://stackoverflow.com/questions/7901864/git-conflict-markers)).
* Add the files to _staged_ (just _git add_ them).
* If there is a conflict with a submodule, you can't use Visual Studio Code
  to add the submodule to the staged files; you'll need to manually to the
  `git add` from the command line.
* Continue rebasing with `git rebase --continue` until done.

## Fix conflicts after pull

After fixing the conflicts with _master_ the working copy of the development
branch might no longer merge with the upstream development branch. So I just
do a `git pull`, edit conflicts (if any) using Visual Studio Code and then
commit the changes back before pushing the result to GitLab.

## Accept the merge request

When accepting the merge request in GitLab, it might be a good idea to
edit the automatically generated merge message rather than letting GitLab
do everything by itself.
