module.exports = {
    // contracts_build_directory: "./build",
    networks: {
        development: {
            host: "127.0.0.1",
            port: 8545,
            network_id: "*", // Match any network id
            from: "0xc0bcd945a5508aabec2d959fe7b7ae1917b4086b"
        }
    }
};
