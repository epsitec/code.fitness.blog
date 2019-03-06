+++
categories = ["tools"]
date = "2019-03-06T06:13:44+01:00"
title = "When SVN Cleanup requires a cleanup"
+++

**Tortoise SVN** crashed while checking in some files from my SVN
working directory.

Trying to run _SVN > Cleanup_ would not work, even from the command line:

> svn: E155037: Previous operation has not finished; run 'cleanup'
> if it was interrupted

Yeah, that was exactly what I was trying to do. So running `svn cleanup`
would just tell me to run `svn cleanup` to fix things up so that I
could ... clean up the working copy.

I suspected that some process was still running - so I rebooted my
machine. But no, the problem did not disappear, which hinted me to a
corruption of the `.svn` state.

## Fixing svn cleanup E155037

To solve this issue, the quickest solution is to open the `.svn/wc.db`
database, used by SVN to maintain its internal state, e.g. using an interactive
SQLite browser (or a command line interface) and clear the `work_queue`
table:

```SQL
delete from work_queue
```

Don't forget to commit the changes, then run `svn cleanup` again, from the command line or directly from Tortoise SVN, and everything should be working
fine, at last.
