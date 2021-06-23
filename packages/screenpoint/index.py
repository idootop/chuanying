import screenpoint
import cv2
import sys
import json


view_path = sys.argv[1]

if view_path == "ok":
    print("ok")
else:
    screen_path = sys.argv[2]
    srcX = float(sys.argv[3])
    srcY = float(sys.argv[4])
    width = float(sys.argv[5])
    height = float(sys.argv[6])

    view = cv2.imread(view_path, 0)
    screen = cv2.imread(screen_path, 0)
    c, t, b = screenpoint.project(view, screen, srcX, srcY, width, height)

    result = {
        "center": c,
        "topLeft": t,
        "bottomRight": b,
    }

    print(json.dumps(result))
