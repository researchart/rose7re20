# -*- coding: utf-8 -*-
"""
biosppy.signals.eda
-------------------

This module provides methods to process Electrodermal Activity (EDA)
signals, also known as Galvanic Skin Response (GSR).

:copyright: (c) 2015-2018 by Instituto de Telecomunicacoes
:license: BSD 3-clause, see LICENSE for more details.
"""

# Imports
# compat
from __future__ import absolute_import, division, print_function
from six.moves import range

import sys

# 3rd party
import numpy as np

# local
import tools as st
import utils

def test(): 
  y = tools.prova()
  
  return y

def kbk_scr(signal=None, sampling_rate=1000., min_amplitude=0.1):
    """KBK method to extract Skin Conductivity Responses (SCR) from an
    EDA signal.

    Follows the approach by Kim *et al.* [KiBK04]_.

    Parameters
    ----------
    signal : array
        Input filterd EDA signal.
    sampling_rate : int, float, optional
        Sampling frequency (Hz).
    min_amplitude : float, optional
        Minimum treshold by which to exclude SCRs.
    
    Returns
    -------
    onsets : array
        Indices of the SCR onsets.
    peaks : array
        Indices of the SRC peaks.
    amplitudes : array
        SCR pulse amplitudes.

    References
    ----------
    .. [KiBK04] K.H. Kim, S.W. Bang, and S.R. Kim, "Emotion recognition
       system using short-term monitoring of physiological signals",
       Med. Biol. Eng. Comput., vol. 42, pp. 419-427, 2004

    """

    # check inputs
    if signal is None:
        raise TypeError("Please specify an input signal.")

    # differentiation
    df = np.diff(signal)

    # smooth
    size = int(1. * sampling_rate)
    df, _ = st.smoother(signal=df, kernel='bartlett', size=size, mirror=True)
    
    
    
    # zero crosses
    zeros, = st.zero_cross(signal=df, detrend=False)
    
    
    
    if zeros[0] != 0:
      if np.all(df[:zeros[0]] > 0):
          zeros = zeros[1:]
      if np.all(df[zeros[-1]:] > 0):
          zeros = zeros[:-1]
          
    
    
    # exclude SCRs with small amplitude
    thr = min_amplitude * np.max(df)

    scrs, amps, ZC, pks = [], [], [], []
    for i in range(0, len(zeros) - 1, 2):
        scrs += [df[zeros[i]:zeros[i + 1]]]
        aux = scrs[-1].max()
        if aux > thr:
            amps += [aux]
            ZC += [zeros[i]]
            ZC += [zeros[i + 1]]
            pks += [zeros[i] + np.argmax(df[zeros[i]:zeros[i + 1]])]

    scrs = np.array(scrs).ravel()
    amps = np.array(amps).ravel()
    ZC = np.array(ZC).ravel()
    pks = np.array(pks).ravel()
    onsets = ZC[::2]

    # output
    args = (onsets, pks, amps)
    names = ('onsets', 'peaks', 'amplitudes')

    data = {'onset': np.array(onsets).ravel() ,'peaks': pks, 'amplitudes': amps}
    
    df = pd.DataFrame(data)
    
    return (df)

