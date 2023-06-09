# cnae_do45x_service_iam

## Test users
| Group  | Username | Password | Email |
| ------------- | ------------- | ------------- | ------------- |
| admin | test-admin | Test123456! | admin@test.test |
| professor | test-professor | Test123456! | professor@test.test |
| student | test-student | Test123456! | student@test.test |

## JWT example
```json
{
    "sub": "1364b8e2-3051-7059-b5c7-ea72d517de2d",
    "cognito:groups": [
        "admin"
    ],
    "iss": "https://cognito-idp.eu-central-1.amazonaws.com/eu-central-1_DRfo8lOHW",
    "cognito:username": "test-admin",
    "origin_jti": "9b288e8a-e7d3-4dff-a08e-442d7693dc4e",
    "aud": "46lnrh5tqncurcagctvcprd0gm",
    "event_id": "f15f9611-752b-4e99-bc48-2400e6ccdda0",
    "token_use": "id",
    "auth_time": 1686056893,
    "exp": 1686060493,
    "iat": 1686056893,
    "jti": "167c2d01-99b6-4454-9e8b-4a976eb6b951",
    "email": "admin@test.test"
}
```

## Curl examples
### Create user
```
curl --location --request POST 'https://cognito-idp.eu-central-1.amazonaws.com' \
--header 'X-Amz-Target: AWSCognitoIdentityProviderService.SignUp' \
--header 'Content-Type: application/x-amz-json-1.1' \
--data-raw '{
   "ClientId": "<cognito-client-id>",
   "Password": "<password>",
   "UserAttributes": [ 
      { 
         "Name": "email",
         "Value": "<email>"
      }
   ],
   "Username": "<username>"
}'
```

### Login
```
curl --location --request POST 'https://cognito-idp.eu-central-1.amazonaws.com' \
--header 'X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth' \
--header 'Content-Type: application/x-amz-json-1.1' \
--data-raw '{
   "AuthFlow": "USER_PASSWORD_AUTH",
   "AuthParameters": { 
      "USERNAME" : "<username>",
      "PASSWORD" : "<password>"
   },
   "ClientId": "<cognito-client-id>"
}'
```

### Example api
Returns the content of your token. Use the IdToken from the login response.
```
curl https://api.cnae-x.de/dev/example -H "Accept: application/json" -H "Authorization: Bearer <IdToken>"
```
```
curl https://api.cnae-x.de/dev/gateway-test -H "Accept: application/json" -H "Authorization: Bearer <IdToken>"
```
