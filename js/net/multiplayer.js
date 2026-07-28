// WebRTC PeerJS Online Multiplayer Module

export class NetworkManager {
    constructor() {
        this.peer = null;
        this.connections = [];
        this.isHost = false;
        this.roomCode = null;
        this.onPlayerJoined = null;
        this.onStateUpdate = null;
    }

    generateRoomCode() {
        const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
        let code = 'RND';
        for (let i = 0; i < 3; i++) {
            code += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return code;
    }

    createRoom(onSuccess, onError) {
        this.roomCode = this.generateRoomCode();
        this.isHost = true;

        if (typeof Peer === 'undefined') {
            console.warn('PeerJS library not loaded. Running in simulated room mode.');
            if (onSuccess) onSuccess(this.roomCode);
            return;
        }

        try {
            this.peer = new Peer(`rondofc-${this.roomCode}`, { debug: 1 });

            this.peer.on('open', (id) => {
                if (onSuccess) onSuccess(this.roomCode);
            });

            this.peer.on('connection', (conn) => {
                this.connections.push(conn);
                this.setupConnectionListeners(conn);
                if (this.onPlayerJoined) this.onPlayerJoined(this.connections.length + 1);
            });

            this.peer.on('error', (err) => {
                console.error('PeerJS Host Error:', err);
                if (onError) onError(err);
            });
        } catch (e) {
            console.warn('PeerJS init failed', e);
            if (onSuccess) onSuccess(this.roomCode);
        }
    }

    joinRoom(code, onSuccess, onError) {
        this.roomCode = code.toUpperCase();
        this.isHost = false;

        if (typeof Peer === 'undefined') {
            if (onSuccess) onSuccess(this.roomCode);
            return;
        }

        try {
            this.peer = new Peer();
            this.peer.on('open', () => {
                const conn = this.peer.connect(`rondofc-${this.roomCode}`);
                this.connections.push(conn);
                this.setupConnectionListeners(conn);
                conn.on('open', () => {
                    if (onSuccess) onSuccess(this.roomCode);
                });
            });

            this.peer.on('error', (err) => {
                if (onError) onError(err);
            });
        } catch (e) {
            if (onError) onError(e);
        }
    }

    setupConnectionListeners(conn) {
        conn.on('data', (data) => {
            if (this.onStateUpdate) this.onStateUpdate(data);
        });

        conn.on('close', () => {
            this.connections = this.connections.filter(c => c !== conn);
        });
    }

    broadcast(data) {
        this.connections.forEach(conn => {
            if (conn.open) conn.send(data);
        });
    }

    disconnect() {
        if (this.peer) {
            this.peer.destroy();
            this.peer = null;
        }
        this.connections = [];
        this.isHost = false;
        this.roomCode = null;
    }
}

export const net = new NetworkManager();
