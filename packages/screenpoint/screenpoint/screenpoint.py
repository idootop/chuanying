# -*- coding: utf-8 -*-
import numpy as np
import cv2

sift = cv2.SIFT_create()


def project(view, screen, srcX=0, srcY=0, width=1, height=1):
    '''
    获取view上子图坐标在screen中的坐标

    坐标系：左上角(0,0)，右下角(1,1)
    '''
    # 搜索图片特征点
    kp_screen, des_screen = sift.detectAndCompute(screen, None)
    kp_view, des_view = sift.detectAndCompute(view, None)

    # 使用BFMatcher进行暴力匹配
    bf = cv2.BFMatcher.create(cv2.NORM_L2)
    matches = matches = bf.knnMatch(des_screen, des_view, k=2)

    # 有效的匹配点
    good = []
    for m, n in matches:
        if m.distance < 0.7 * n.distance:
            good.append(m)

    # 需要4个匹配点才能得到有效的透视转换矩阵
    if len(good) < 6:
        return 0, 0, 1, 1

    screen_pts = np.float32(
        [kp_screen[m.queryIdx].pt for m in good]).reshape(-1, 1, 2)
    view_pts = np.float32(
        [kp_view[m.trainIdx].pt for m in good]).reshape(-1, 1, 2)

    # 透视转换矩阵M
    M, mask = cv2.findHomography(view_pts, screen_pts, cv2.RANSAC, 5.0)

    # 获取尺寸
    view_h, view_w = view.shape
    view_h -= 1
    view_w -= 1
    screen_h, screen_w = screen.shape
    screen_h -= 1
    screen_w -= 1

    # 相机坐标
    center = [view_w/2, view_h/2]
    topLeft = [view_w * srcX, view_h*srcY]
    bottomRight = [topLeft[0]+view_w * width, topLeft[1]+view_h*height]

    pts = np.float32([center, topLeft, bottomRight]).reshape(-1, 1, 2)

    # 转屏幕坐标
    dst = cv2.perspectiveTransform(pts, M)

    x0, y0 = np.int32(dst[0][0])/[screen_w, screen_h]
    pCenter = [x0, y0]
    x1, y1 = np.int32(dst[1][0])/[screen_w, screen_h]
    pTopLeft = [x1, y1]
    x2, y2 = np.int32(dst[2][0])/[screen_w, screen_h]
    pBottomRight = [x2, y2]

    return pCenter, pTopLeft, pBottomRight


