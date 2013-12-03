# Click demo app

This demo app serves two purposes.

1. A demonstration of integrating Click into an application that already uses a separate Sequel database.
2. A demonstration of Click in an app with a known memory leak. To leak objects, connect to the `/make_objects/:count` endpoint.

To inspect Click on the live application, run `click-console sqlite:///tmp/click_demo_memory.sqlite`.
