# Fixing `<screen>`

When you have misaligned `<promp>` and `<command>` tags, this script can help
you.

Let's assume, you have this input:

```xml
<screen>
 <prompt>&lt; </prompt>
 <command>sudo</command>
 <command>foo</command>
</screen>
```

The prompt contains linebreak and the command should appear in one line.
Applying this script gives you the following output:

```xml
<screen><prompt>&lt; </prompt> <command>sudo</command> <command>foo</command>
</screen>
```

Other `<screen>`s with other tags are kept as is.
