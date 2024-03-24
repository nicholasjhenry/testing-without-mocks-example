# Testing Without Mocks

Applying <https://www.jamesshore.com/v2/projects/nullables> to Elixir.

## Development

    git clone https://github.com/nicholasjhenry/testing-without-mocks-example.git
    mix test

## Running

Command line:

    script/rot13 hello
    # => uryyb

Server:

    script/server 4001
    # New terminal
    brew install httpie
    http http://localhost:4001/rot13/transform text=world
    # => { "transform": "uryyb" }
