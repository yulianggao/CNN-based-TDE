import numpy as np
import matlab.engine
import scipy.io as scio
import tensorflow as tf

filename = 'SNR20_QAM16'
eng = matlab.engine.start_matlab()
data = scio.loadmat('mat/'+filename+'.mat')

ofdm = data['ofdm']
ofdm_dict = {'nc': float(ofdm['nc'][0, 0]),
             'ber': float(ofdm['ber'][0, 0]),
             'M': float(ofdm['M'][0, 0]),
             'Nd': int(ofdm['Nd'][0, 0]),
             'Nf': int(ofdm['Nf'][0, 0]),
             'test': int(ofdm['test'][0, 0]),
             'train': int(ofdm['train'][0, 0]),
             'Ns': int(ofdm['Ns'][0, 0]),
             'snr': int(ofdm['snr'][0, 0]),
             'channel': int(ofdm['channel'][0, 0]),
             'fc': int(ofdm['fc'][0, 0] / 1e6),
             'fs': int(ofdm['fs'][0, 0] / 1e6)}

print('------------------------------')
print('Constellation: %2d-QAM' % ofdm_dict['M'])
print('FFT Points: %d' % ofdm_dict['Nf'])
print('Subcarriers: %d' % ofdm_dict['Nd'])
print('Sample rate: %d MSPS' % ofdm_dict['fs'])
print('------------------------------')
print('SNR: %d dB' % ofdm_dict['snr'])
print('Length of channel: %d' % ofdm_dict['channel'])
print('------------------------------')
print('Original BER: %.3e' % ofdm_dict['ber'])
print('------------------------------')

# Test-set
Ns_test = ofdm_dict['test']
txSig_test = data['txSig_test']
rxSig_test = data['rxSig_test']
qamIn_test = data['qamIn_test']

# Training-set
Ns_train = ofdm_dict['train']
txSig_train = data['txSig_train']
rxSig_train = data['rxSig_train']

########################################################################################################################
tf.set_random_seed(1)


def bias_variable(shape, name):
    return tf.Variable(tf.constant(value=0.01, shape=shape, dtype=tf.float32), name=name)


def weight_variable(shape, init=None, name=None):
    return tf.Variable(tf.truncated_normal(shape=shape, mean=0.0, stddev=0.07), name=name)


def fc(x, weight, bias, activation=None, name=None):
    with tf.name_scope(name):
        dense = tf.matmul(a=x, b=weight) + bias
        if activation is not None:
            return activation(dense)
        else:
            return dense


def conv1d(x, weight, bias, activation=None, bn=False, training=False, name=None):
    conv = tf.nn.conv1d(value=x, filters=weight, stride=1, padding='SAME', name=name) + bias
    if bn is True:
        batch_normalization = tf.layers.batch_normalization(inputs=conv, training=training)
        if activation is not None:
            return activation(batch_normalization)
        else:
            return batch_normalization
    else:
        if activation is not None:
            return activation(conv)
        else:
            return conv


def expand(tensor, channel):
    concatenation = []
    for i in range(channel):
        concatenation.append(tensor[:, :, i])
    return tf.concat(values=concatenation, axis=1)


# Hyper-parameters
LR = 1e-3
EPOCH = 1
B = 100
Iter = Ns_train//B
# Size of CNN
conv_channel = 32
filter_length = ofdm_dict['channel']
NN = ofdm_dict['Nf'] * conv_channel


# IO, biases and weights
xs = tf.placeholder(dtype=tf.float32, shape=[None, ofdm_dict['Nf']], name='xs')
ys = tf.placeholder(dtype=tf.float32, shape=[None, ofdm_dict['Nf']], name='ys')
b = {'conv1': bias_variable(shape=[conv_channel, ], name='bias_conv1'),
     'fc1': bias_variable(shape=[NN, ], name='bias_fc1'),
     'eq_out': bias_variable(shape=[ofdm_dict['Nf'], ], name='bias_eq_out')}
W = {'conv1': weight_variable(shape=[filter_length, 1, conv_channel], name='weight_conv1'),
     'fc1': weight_variable(shape=[NN, NN], name='weight_fc1'),
     'eq_out': weight_variable(shape=[NN, ofdm_dict['Nf']], name='weight_eq_out')}


# Neural network
conv_in = tf.reshape(tensor=xs, shape=[-1, ofdm_dict['Nf'], 1])
conv1 = conv1d(x=conv_in, weight=W['conv1'], bias=b['conv1'], activation=tf.nn.tanh, name='conv1')
conv_out = expand(tensor=conv1, channel=conv_channel)
fc1 = fc(x=conv_out, weight=W['fc1'], bias=b['fc1'], activation=tf.nn.tanh, name='fc1')
eq_out = fc(x=fc1, weight=W['eq_out'], bias=b['eq_out'], activation=None, name='eq_out')


# Loss and optimizer
loss = tf.losses.mean_squared_error(labels=ys, predictions=eq_out)
with tf.control_dependencies(tf.get_collection(tf.GraphKeys.UPDATE_OPS)):
    train_step = tf.train.AdamOptimizer(LR).minimize(loss)


# Train and test
sess = tf.Session()
sess.run(tf.global_variables_initializer())
index = np.arange(Ns_train)
ber = np.zeros(shape=[EPOCH, Iter], dtype=np.float32)
result = np.zeros(shape=txSig_test.shape, dtype=np.float32)
for i in range(EPOCH):
    print('\nEpoch: ', i + 1)
    start, end = 0, B
    np.random.shuffle(index)
    for j in range(Iter):
        # Train
        batch_x = rxSig_train[index[start:end], :]
        batch_y = txSig_train[index[start:end], :]
        sess.run(train_step, feed_dict={xs: batch_x, ys: batch_y})
        # Test
        result = sess.run(eq_out, feed_dict={xs: rxSig_test})
        ber[i, j] = eng.dem_ofdm(ofdm_dict, matlab.double(result.tolist()), matlab.double(qamIn_test.tolist()))
        print('Iter - %d BER = %.3e' % (j + 1, ber[i, j]))
        # Next Batch
        end += B
        start += B
sess.close()
mat_dict = {'result': result,
            'ofdm': ofdm_dict,
            'current': np.reshape(ber, EPOCH*Iter)}
scio.savemat('mat/'+filename+'_C'+str(conv_channel)+'_cnn.mat', mat_dict)