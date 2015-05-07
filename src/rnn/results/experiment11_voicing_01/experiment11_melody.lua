rootdir = '../results'
experiment_name = 'experiment11_voicing'
resume = true
device = 2
batchSize=100
maxNumSongsTRAIN      = 999
maxNumSongsVALIDATION = 999

print('==> switching to CUDA')
require 'cunn'
cutorch.setDevice(device)


function formatnum(num)
	str = tostring(num)
	while string.len(str) < 2 do
		str = '0' .. str
	end
	return str
end

if resume==false then
	status = false
	num = 1
	experiments = ""
	while status ~= true and num < 10 do
		tag = experiment_name .. '_' .. formatnum(num)
		experiments = paths.concat(rootdir, tag)
		response = os.rename(experiments,experiments)
		status = response ~= true
		num = num+1
		print(status)
	end
	sys.execute('mkdir -p ' .. experiments)

	sys.execute('cp *.lua ' .. experiments)

	results = paths.concat(experiments, 'results')
	sys.execute('mkdir -p ' .. results)
	path = experiments
	save = results
else
	path = './'
	save = 'results'
end


trainParams_SGD = {}
trainParams_SGD[1] = {
	numEpochs = 50,
	momentum = 0.99,
	learningRate = 1e-3,
	learningRateDecay = 1e-7,
	optimization = "SGD"
}
trainParams_ADA = {}
trainParams_ADA[1] = {
	numEpochs = 50,
	momentum = 0.99,
	learningRate = 1,
	learningRateDecay = 1e-7,
	optimization = "ADADELTA"
}



params = {}
--[[
params['convLSTM_16c41_16c5_170f_ADA'] = {							
							   ['device']=2,
							   ['model']='LSTM2_Conv',
							   ['max_grad_norm']=3,
							   ['peepholes']=false,
							   ['dropout']=0,
							   ['avgBPTT']=true,
							   ['kL']=20,
							   ['kR']=0,
							   ['layers']=2,
							   ['binarylabel']=false,
							   ['trainParams']=trainParams_ADA,
							   ['conv'] = {
								   			[1] = {
								   				nOutputFrame = 16,
								   				kW = 41, -- 84->44
								   				dW = 1
								   				},
								   			[2] = {
								   				nOutputFrame = 16,
								   				kW = 5, -- 44->40
								   				dW = 1
								   				}
							   				}, -- fullyconnected = 16*40
							   	['convfc'] = 85*2
					   			}]]

params['convLSTM_16c41_16c5_170f_SGD'] = {							
							   ['device']=4,
							   ['model']='LSTM2_Conv',
							   ['max_grad_norm']=3,
							   ['peepholes']=false,
							   ['dropout']=0,
							   ['avgBPTT']=true,
							   ['kL']=20,
							   ['kR']=0,
							   ['layers']=2,
							   ['binarylabel']=false,
							   ['trainParams']=trainParams_SGD,
							   ['conv'] = {
								   			[1] = {
								   				nOutputFrame = 16,
								   				kW = 41, -- 84->44
								   				dW = 1
								   				},
								   			[2] = {
								   				nOutputFrame = 16,
								   				kW = 5, -- 44->40
								   				dW = 1
								   				}
							   				}, -- fullyconnected = 16*40
							   	['convfc'] = 85*2
					   			}



opt = {}
-- global:
opt['seed'] = 1 -- fixed input seed for repeatable experiments
opt['threads'] = 8 -- number of threads
opt['device'] = device -- number of threads
opt['path'] = path -- location of source files
opt['binarylabel'] = false -- detect voicing=true, detect melody=false
-- data:
opt['maxNumSongsTRAIN'] = maxNumSongsTRAIN
opt['maxNumSongsVALIDATION'] = maxNumSongsVALIDATION
opt['preprocessedData'] = '/home/justin/cqt/t7b/' -- where the preprocessed data lives
opt['loadDataFile'] = '1_data.lua' -- file used to load data
opt['normalize'] = true
opt['normalizeSTD'] = true
opt['normalizeFREQ'] = false
opt['mode'] = 'Temporal'
-- model:
opt['layers'] = 1
opt['rnn_size'] = 200
opt['num_inputs'] = 84
opt['peepholes'] = true
-- loss:
opt['loss'] = 'nll' -- type of loss function to minimize: nll | mse | margin
-- training:
opt['trainFile'] = '4_train.lua'
opt['save'] = save -- subdirectory to save/log experiments in
opt['plot'] = true -- live plot
opt['optimization'] = 'ADADELTA' -- optimization method: SGD | ASGD | CG | LBFGS
opt['model'] = 'cuda1' -- type of model to construct: linear | mlp | convnet
opt['dropout'] = 0.5 -- max number of epochs to run
opt['trainParams'] = trainParams
opt['learningRate'] = 1e-3 -- learning rate at t= 0
opt['learningeRateDecay'] = 1e-7 -- learning rate decay
opt['batchSize'] = batchSize -- mini-batch size (1 =  pure stochastic)
opt['initbatchSize'] = initbatchSize -- begin with minbatchsize, then switch to batchsize at t0
opt['batchLearningRate'] = 1e-4 -- begin with minbatchsize, then switch to batchsize at t0
opt['weightDecay'] = 0 -- weight decay (SGD only)
opt['momentum'] = 0.95 -- momentum (SGD only)
opt['t0'] = 1 -- start averaging at t0 (ASGD only), in nb of epochs
opt['lambda'] = 1e-4 -- ASGD lambda
opt['type'] = 'cuda' -- type: double | float | cuda
opt['maxEpochs'] = maxEpochs -- max number of epochs to run
opt['max_grad_norm'] = 2
opt['init_weight'] = 0.05
opt['avgBPTT'] = false
-- test:
opt['runValidation'] = true -- toggle validation
opt['runTest'] = false -- toggle test


for key,optlist in pairs(params) do
	opt['tag'] = key -- 'name of run, used as name for results folder')
	for optname,optval in pairs(optlist) do 
		opt[optname] = optval
	end

	epoch = 1
	if resume then
		dofile 'resume.lua'
	else
		dofile (paths.concat(experiments, 'doall.lua'))
	end
end















