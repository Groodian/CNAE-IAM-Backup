const { CognitoIdentityProviderClient, AdminAddUserToGroupCommand } = require("@aws-sdk/client-cognito-identity-provider");

exports.handler = async (event) => {
    var params = {
        GroupName: 'student',
        UserPoolId: event.userPoolId,
        Username: event.userName
    };

    const client = new CognitoIdentityProviderClient();
    const command = new AdminAddUserToGroupCommand(params);
    const response = await client.send(command);

    return event;
};
