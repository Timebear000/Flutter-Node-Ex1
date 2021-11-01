const express = require('express');
const app = express();
const PORT = process.env.PORT || 4000;
const server = app.listen(PORT, () => {
    console.log('Server is Started on ', PORT);
});
const io = require('socket.io')(server);
const connentUser = new Set();
io.on('connection', (socket) => {
    console.log("Connected Successfully", socket.id);
    connentUser.add(socket.id);
    io.emit('conented-user', connentUser.size);
    socket.on('disconnect', () => {
        console.log("Disconneted", socket.id);
        connentUser.delete(socket.id);
        io.emit('conented-user', connentUser.size);

    });
    socket.on('message', (data) => {
        console.log(data);
        socket.broadcast.emit('message-receive',data);
    });
});


