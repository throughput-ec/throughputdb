CALL dbms.security.createUser('gitwriter', '+?yY-y9M^KBvKQvL', requirePasswordChange=false)
CALL dbms.security.addRoleToUser('editor', 'gitwriter')
