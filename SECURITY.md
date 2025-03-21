# Security

We take security seriously.  If you believe you have discovered a vulnerability, please [file an issue](https://github.com/StartAutomating/AI/issues).

## Special Security Considerations

AI is not inherantly dangerous, but what comes out of them might well be.

In order to avoid data poisoning attacks, please _never_ directly run any code from the internet that you do not trust.

Please also assume all WebSockets are untrustworthy.

There are a few easy ways to do this.

AI responses should never:

1. Be piped into `Invoke-Expression`
2. Be expanded with `.ExpandString`
3. Be directly placed into a `SQL` query

## Ethical AI considerations

AI should be used ethically.  In the case of PowerShell, this can be especially tricky.

PowerShell gives you the ability to deal with vast amounts of information, and significant existing automation capabilities.

With power comes responsbility, and all users of this module are morally (and potentially legally) responsible for the potential harms that callous use of AI can inflict.

If you are aware of ethical misuse of the product, please [file an issue](https://github.com/StartAutomating/AI/issues)

Sunlight is often the best disenfectant.