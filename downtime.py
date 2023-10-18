import requests
import time

def ping_server(server_url):

    while True:
        try:
            response = requests.get(server_url)

            if response.status_code == 200:
                print(f'Server {server_url} is up!')
            else:
                print(f'Server {server_url} is down! Status code: {response.status_code}')
                downtime_start = time.time()  # record when the server started going down
          
                while True:
                    # Check periodically if the server is back up
                    response = requests.get(server_url)
                    if response.status_code == 200:
                        downtime_end = time.time()  # record when the server went back up
                        downtime_duration = downtime_end - downtime_start
                        print(f'Server {server_url} was down for {downtime_duration} seconds')
                        break
                    else:
                        time.sleep(2)  # you can change the time to wait before trying again

        except requests.exceptions.RequestException:
            print(f'Could not connect to {server_url}')
            time.sleep(2)  # wait before trying to connect again

        time.sleep(2)  # wait before pinging the server again

# Call the function
ping_server('https://qa-azure.wandb.io')