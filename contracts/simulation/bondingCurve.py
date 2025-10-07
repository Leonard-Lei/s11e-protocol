import numpy as np
import math
import matplotlib.pyplot as plt


# y=1/(1+e^(-x))
def sigmoid():
    x = np.arange(-100, 100, 0.1)
    y = []
    for t in x:
        y_1 = 1 / (1 + math.exp(-t))
        y.append(y_1)
    plt.plot(x, y, label="sigmoid")
    plt.xlabel("x")
    plt.ylabel("y")
    plt.ylim(0, 1)
    plt.legend()
    plt.show()


# P0=0.00001  x=0时的价格
# k=1  x->正无穷 时的值
# r=1 令时间常数为 横向拉伸
def s11eCurve1():
    cap = 1
    P0 = 0.00001
    K = 1
    r = 1
    print("limit:", K)
    print("P0:", P0)
    print("时间常数：", r)
    x = np.arange(-10, 100, float((cap * 20 + 10) / 100))
    y = []
    for t in x:
        y_1 = K / (1 + (K / P0 - 1) * math.exp((-r * t)))
        y.append(y_1)
    plt.plot(x, y, label="s11eCurve")
    plt.xlabel("x")
    plt.ylabel("y")
    plt.ylim(0, K)
    plt.legend()
    plt.show()


# P0=0.00001  x=0时的价格
# k=1  x->正无穷 时的值
# r=0.1 令时间常数为 r
def s11eCurve2():
    cap = 2
    P0 = 0.00001
    K = 1
    r = 0.5
    print("limit:", K)
    print("P0:", P0)
    print("时间常数：", r)
    x = np.arange(-10, 100, float((cap * 20 + 10) / 100))
    y = []
    for t in x:
        y_1 = K / (1 + (K / P0 - 1) * math.exp((-r * t)))
        y.append(y_1)
    plt.plot(x, y, label="s11eCurve")
    plt.xlabel("x")
    plt.ylabel("y")
    plt.ylim(0, K)
    plt.legend()
    plt.show()

# 参考：https://blog.csdn.net/qq_27158179/article/details/82928620
# P0=0.00001  x=0时的价格
# k=1  x->正无穷 时的值
# r=1 时间常数 调节曲线x轴拉升  0.3~3
def s11eCurve3():
    # 供应量
    cap = 1000000000000
    # 起始价格
    P0 = 0.001
    # 价格上限
    K = 10
    tmp = float(20 / cap)
    r=1
    r_result = tmp*r
    print("limit:", K)
    print("P0:", P0)
    print("时间常数：", r)
    x = np.arange(-10, cap, int((cap + 10) / 100))
    y = []
    for t in x:
        y_1 = K / (1 + (K / P0 - 1) * math.exp((-r_result * t)))
        y.append(y_1)
        print(t, y_1)
    plt.plot(x, y, label="s11eCurve")
    plt.xlabel("x")
    plt.ylabel("y")
    plt.ylim(0, K)
    plt.legend()
    plt.show()


if __name__ == '__main__':
    # sigmoid()
    # s11eCurve1()
    # s11eCurve2()
    s11eCurve3()