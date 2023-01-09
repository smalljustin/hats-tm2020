### POST /api/playerhats
```json
{
  "apiKey": "xxx",
  "playerIDs": [
    "xxx",
	"yyy",
	"zzz"
  ]
}
```

returns json array of user objects

### GET /api/hats

* `$_GET['apiKey']` (optional to get your unapproved hats)

returns json array of hat objects

### POST /api/sethat
```json
{
  "apiKey": "xxx",
  "idHat": "xxx",
  "hatConfig": "xxx"
}
```

returns your user object

### POST /auth/openplanet
```json
{
  "token": "xxx from Auth plugin",
  "clubTag": "LACE",
  "login": "xxx"
}
```
return value:
```json
{
  "apiKey": "xxx"
}
```

### POST /api/keystatus
```json
{
  "apiKey": "xxx",
}
```

returns your user object


### hat object:
```json
{
  "idHat": 107089042176,
  "name": "Cat Ears",
  "author": (user object),
  "approved": true,
  "created": 1673266284,
  "updated": 1673266347
}
```

### user object:
```json
{
  "uid": "09c8c72a-f5b3-4c8e-88fe-0ccba47c6dcb",
  "login": null,
  "displayName": "MisfitMaid",
  "locale": "en",
  "hat": 107089042176,
  "hatConfig": "arbitrary string or null",
  "created": 1673217994,
  "updated": 1673266918
}
```
