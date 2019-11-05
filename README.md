# ghws
Web service to get Github repository and gist information

### Build Requirements
* xinetd
* make
* m4

### Run requirements
* xinetd

### Installation
1. Run ```make setup``` and provide the port number to run service as
2. Run ```sudo make install```

### Usage
Request:  
```
POST /ws/all HTTP/1.1
Content-length: 22
 
{ "arg" : "bng44270" }
```
  
Note: the value of ```Content-length``` should equal the length of the JSON POST data.  Also, the JSON data must be on one line.  
  
Response:  
```
HTTP/1.1 200 OK
Content-Length: LENGTH
Date: TIMESTAMP
  
{
    "repos" : [
        { "name" : "repo_1_name", "http-url" : "https://github.com/user/repo_1_name.git", "ssh-url":"git@github.com:user/repo_1_name.git" },
        ...
        { "name" : "repo_N_name", "url" : "https://github.com/user/repo_N_name", "ssh-url":"git@github.com:user/repo_N_name.git" }
    ],
    "gists" : [
        { "name" : "gist_1_name", "url" : "https://gist.github.com/user/gist_1_hash" },
        ...
        { "name" : "gist_N_name", "url" : "https://gist.github.com/user/gist_N_hash" }
    ]
}
```
Here are the individual resources and the URI they can be queries with:  

| Resource | URI | POST Data |
| --- | --- | --- |
| All Resources | /ws/all | ```{ "arg" : "GITHUB-USER" }``` |
| List of Gists | /ws/gists | ```{ "arg" : "GITHUB-USER" }``` |
| List of Repositories | /ws/repos | ```{ "arg" : "GITHUB-USER" }``` |
| URL of Raw Gist | /ws/gisturl |  ```{ "arg" : "GIST-URL" }``` |
