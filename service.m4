service quickstat
{
        port            = PORT
        socket_type     = stream
        protocol        = tcp
        wait            = no
        user            = root
        server          = PATH/bin/ghws.sh
}
