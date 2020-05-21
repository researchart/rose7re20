#https://raw.githubusercontent.com/PIA-Group/BioSPPy/master/biosppy/signals/tools.py


from __future__ import absolute_import, division, print_function
from six.moves import range
import six

import utils

# 3rd party
import numpy as np
import scipy.signal as ss
from scipy import interpolate, optimize
from scipy.stats import stats




def _get_window(kernel, size, **kwargs):
    """Return a window with the specified parameters.

    Parameters
    ----------
    kernel : str
        Type of window to create.
    size : int
        Size of the window.
    ``**kwargs`` : dict, optional
        Additional keyword arguments are passed to the underlying
        scipy.signal.windows function.

    Returns
    -------
    window : array
        Created window.

    """

    # mimics scipy.signal.get_window
    if kernel in ['blackman', 'black', 'blk']:
        winfunc = ss.blackman
    elif kernel in ['triangle', 'triang', 'tri']:
        winfunc = ss.triang
    elif kernel in ['hamming', 'hamm', 'ham']:
        winfunc = ss.hamming
    elif kernel in ['bartlett', 'bart', 'brt']:
        winfunc = ss.bartlett
    elif kernel in ['hanning', 'hann', 'han']:
        winfunc = ss.hann
    elif kernel in ['blackmanharris', 'blackharr', 'bkh']:
        winfunc = ss.blackmanharris
    elif kernel in ['parzen', 'parz', 'par']:
        winfunc = ss.parzen
    elif kernel in ['bohman', 'bman', 'bmn']:
        winfunc = ss.bohman
    elif kernel in ['nuttall', 'nutl', 'nut']:
        winfunc = ss.nuttall
    elif kernel in ['barthann', 'brthan', 'bth']:
        winfunc = ss.barthann
    elif kernel in ['flattop', 'flat', 'flt']:
        winfunc = ss.flattop
    elif kernel in ['kaiser', 'ksr']:
        winfunc = ss.kaiser
    elif kernel in ['gaussian', 'gauss', 'gss']:
        winfunc = ss.gaussian
    elif kernel in ['general gaussian', 'general_gaussian', 'general gauss',
                    'general_gauss', 'ggs']:
        winfunc = ss.general_gaussian
    elif kernel in ['boxcar', 'box', 'ones', 'rect', 'rectangular']:
        winfunc = ss.boxcar
    elif kernel in ['slepian', 'slep', 'optimal', 'dpss', 'dss']:
        winfunc = ss.slepian
    elif kernel in ['cosine', 'halfcosine']:
        winfunc = ss.cosine
    elif kernel in ['chebwin', 'cheb']:
        winfunc = ss.chebwin
    else:
        raise ValueError("Unknown window type.")

    try:
        window = winfunc(size, **kwargs)
    except TypeError as e:
        raise TypeError("Invalid window arguments: %s." % e)

    return window

def smoother(signal=None, kernel='boxzen', size=10, mirror=True, **kwargs):
    """Smooth a signal using an N-point moving average [MAvg]_ filter.

    This implementation uses the convolution of a filter kernel with the input
    signal to compute the smoothed signal [Smit97]_.

    Availabel kernels: median, boxzen, boxcar, triang, blackman, hamming, hann,
    bartlett, flattop, parzen, bohman, blackmanharris, nuttall, barthann,
    kaiser (needs beta), gaussian (needs std), general_gaussian (needs power,
    width), slepian (needs width), chebwin (needs attenuation).

    Parameters
    ----------
    signal : array
        Signal to smooth.
    kernel : str, array, optional
        Type of kernel to use; if array, use directly as the kernel.
    size : int, optional
        Size of the kernel; ignored if kernel is an array.
    mirror : bool, optional
        If True, signal edges are extended to avoid boundary effects.
    ``**kwargs`` : dict, optional
        Additional keyword arguments are passed to the underlying
        scipy.signal.windows function.

    Returns
    -------
    signal : array
        Smoothed signal.
    params : dict
        Smoother parameters.

    Notes
    -----
    * When the kernel is 'median', mirror is ignored.

    References
    ----------
    .. [MAvg] Wikipedia, "Moving Average",
       http://en.wikipedia.org/wiki/Moving_average
    .. [Smit97] S. W. Smith, "Moving Average Filters - Implementation by
       Convolution", http://www.dspguide.com/ch15/1.htm, 1997

    """

    # check inputs
    if signal is None:
        raise TypeError("Please specify a signal to smooth.")

    length = len(signal)

    if isinstance(kernel, six.string_types):
        # check length
        if size > length:
            size = length - 1

        if size < 1:
            size = 1

        if kernel == 'boxzen':
            # hybrid method
            # 1st pass - boxcar kernel
            aux, _ = smoother(signal,
                              kernel='boxcar',
                              size=size,
                              mirror=mirror)

            # 2nd pass - parzen kernel
            smoothed, _ = smoother(aux,
                                   kernel='parzen',
                                   size=size,
                                   mirror=mirror)

            params = {'kernel': kernel, 'size': size, 'mirror': mirror}

            args = (smoothed, params)
            names = ('signal', 'params')

            return utils.ReturnTuple(args, names)

        elif kernel == 'median':
            # median filter
            if size % 2 == 0:
                raise ValueError(
                    "When the kernel is 'median', size must be odd.")

            smoothed = ss.medfilt(signal, kernel_size=size)

            params = {'kernel': kernel, 'size': size, 'mirror': mirror}

            args = (smoothed, params)
            names = ('signal', 'params')

            return utils.ReturnTuple(args, names)

        else:
            win = _get_window(kernel, size, **kwargs)

    elif isinstance(kernel, np.ndarray):
        win = kernel
        size = len(win)

        # check length
        if size > length:
            raise ValueError("Kernel size is bigger than signal length.")

        if size < 1:
            raise ValueError("Kernel size is smaller than 1.")

    else:
        raise TypeError("Unknown kernel type.")

    # convolve
    w = win / win.sum()
    if mirror:
        aux = np.concatenate(
            (signal[0] * np.ones(size), signal, signal[-1] * np.ones(size)))
        smoothed = np.convolve(w, aux, mode='same')
        smoothed = smoothed[size:-size]
    else:
        smoothed = np.convolve(w, signal, mode='same')

    # output
    params = {'kernel': kernel, 'size': size, 'mirror': mirror}
    params.update(kwargs)

    args = (smoothed, params)
    names = ('signal', 'params')

    return utils.ReturnTuple(args, names)


def zero_cross(signal=None, detrend=False):
    """Locate the indices where the signal crosses zero.

    Parameters
    ----------
    signal : array
        Input signal.
    detrend : bool, optional
        If True, remove signal mean before computation.

    Returns
    -------
    zeros : array
        Indices of zero crossings.

    Notes
    -----
    * When the signal crosses zero between samples, the first index
      is returned.

    """

    # check inputs
    if signal is None:
        raise TypeError("Please specify an input signal.")

    if detrend:
        signal = signal - np.mean(signal)

    # zeros
    df = np.diff(np.sign(signal))
    zeros = np.nonzero(np.abs(df) > 0)[0]

    return utils.ReturnTuple((zeros,), ('zeros',))

