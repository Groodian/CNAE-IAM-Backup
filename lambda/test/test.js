const jwt_decode = require('jwt-decode');

exports.handler = async (event) => {
    const tokenDecode = jwt_decode(event.headers.authorization);

    return  {
        statusCode: 200,
        body: JSON.stringify(tokenDecode),
    };
};
