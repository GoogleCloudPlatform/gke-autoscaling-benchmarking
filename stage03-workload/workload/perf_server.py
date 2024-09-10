# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from flask import Flask
import socket
import time

app = Flask(__name__)
hostname = socket.gethostname()

def calculate_fibonacci(n):
  """Calculates the nth Fibonacci number recursively
  (inefficient for the sake of CPU load)
  """
  if n <= 1:
    return n
  else:
    return calculate_fibonacci(n - 1) + calculate_fibonacci(n - 2)

@app.route('/calculate')
def do_calculation():
  start_time = time.time()
  result = calculate_fibonacci(30)  # Adjust the Fibonacci number for load
  end_time = time.time()

  return [{
    'result': result,
    'calculation_time': end_time - start_time,
    'timestamp': start_time,
    'pod_id': hostname
    }]

if __name__ == '__main__':
  app.run(debug=True, host='0.0.0.0', port=5000)
