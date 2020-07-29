# Security Audit

## Passwords

Possibly the most important rule of technology in general is never share your password! Whether that be in person or embedded in code somewhere; the password has to be secure and private. Otherwise you're giving hackers and easy job to wreak havoc in your PC, Servers or Accounts.

This could be as simple as password to your email, but also applies to accounts with potentially sensitive information. Trello, AWS, Jenkins, GitHub, Dropbox etc.

Best Practice to prevent breaches via password is; never store it physically or digitally, never tell anyone, make sure it is complex enough to not be guessed and if it is absolutely necessary to be embedded in a program ensure it is parsed in a way that it is not readable, ie. Hashing AND that the embedding only exists on your local machine and not transferred over the internet on AWS or GitHub.

## Keys - SSH

More DevOps specific are keys, there are a few different types of keys encountered thus far in this stream. One of these are SSH Keys. SSH Keys are keys that reside in a host machine and are used to connect to a target machine; either a VM or AWS machine etc.

These keys come in two parts; private and public. The public key is transferred to the target machine and is generally functionless without its counterpart; the private key. This resides in the host machine and is required to work with the public key to allow access to the other machine.

Naturally, these target machines could hold important data that must remain hidden and protected at all times. To ensure this; the keys should only ever remain in the host machine and the .pub key should ONLY be transferred as and when it is needed. Furthermore; with AWS you can specify IP addresses that are allowed through the SSH port so even if someone does somehow get hold of a key, they cannot use it from an IP that isn't on the list of permitted IPs.

## Keys - AWS

Another *Key* example; are AWS Keys. There are two keys for this; the AWS Access Key and Secret key. Both of these are fundamental to the online security of your AWS account as these keys allow access to users; servers and connections to machines and storage in your AWS region. Because of this; the key is the most important thing to AWS as if it is made available publicly anyone could tamper with your AWS account; causing a potentially unprecedented amount of damage.

They are as, if not more, important than your username and password and must be managed as such; only known within the users of the AWS Account. Therefore, they must be handles with the utmost care and not shared with anyone with whom it doesn't concern.

As AWS keys are needed to create instances from a variety of tools such as Ansible Playbooks and Terraform; extra care just be taken when using these tools and sharing code on platforms such as GitHub. Ansible has a security feature called Ansible Vault that allows you to store aws access and security keys within it. These are hidden in your machine and can be used in reference as a variable; which means that when uploaded the keys will only be a variable; and therefore not a security risk.

Terraform doesn't have the same vault feature as ansible and therefore more care must be taken to ensure the protection of the keys. As the keys must be referenced in the terraform file; when pushed to GitHub these keys will be present which is a major security risk.

To avoid this; you can either keep the keys in a separate document and copy them into the code during run time/ testing. This is a bit inefficient and slow though as you'd have to manually enter the keys every time. Alternatively, you can store variables in a separate file and refer to them in the main.tf file. This is primarily used to keep code DRY but can be used for security by keeping the secret variables separate and then make sure that the file containing them isn't pushed to GitHub by adding it into your .gitignore file. This isn't the most secure way because a small mistake in the .gitignore could make the keys available. The most secure way would be to set the access keys as environment variables on the host machine. Obviously this machine would have to be private and secure; not a public computer. If done correctly then the keys would be safe as direct access to the computer would be the only way to get hold of the keys. 
