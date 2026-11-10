# Writes Tests/LivLivCoreTests/Fixtures/skinned1.vrm: a VRM 1.0 with a skinned strip (head + a three-joint hair chain),
# a morph target bound to "aa", and a spring on the hair with a sphere collider on the head. For the tests only.
import json, struct, sys, os
bones = [('hips', None, [0, 1, 0]), ('spine', 'hips', [0, .12, 0]), ('chest', 'spine', [0, .15, 0]), ('neck', 'chest', [0, .22, 0]),
         ('head', 'neck', [0, .08, 0]), ('hair1', 'head', [0, .1, -.08]), ('hair2', 'hair1', [0, -.1, 0]), ('hair3', 'hair2', [0, -.1, 0]),
         ('leftUpperArm', 'chest', [.18, .18, 0]), ('leftLowerArm', 'leftUpperArm', [.25, 0, 0]), ('leftHand', 'leftLowerArm', [.22, 0, 0]),
         ('rightUpperArm', 'chest', [-.18, .18, 0]), ('rightLowerArm', 'rightUpperArm', [-.25, 0, 0]), ('rightHand', 'rightLowerArm', [-.22, 0, 0]),
         ('leftUpperLeg', 'hips', [.09, -.05, 0]), ('leftLowerLeg', 'leftUpperLeg', [0, -.42, 0]), ('leftFoot', 'leftLowerLeg', [0, -.42, 0]),
         ('rightUpperLeg', 'hips', [-.09, -.05, 0]), ('rightLowerLeg', 'rightUpperLeg', [0, -.42, 0]), ('rightFoot', 'rightLowerLeg', [0, -.42, 0])]
idx = {b[0]: i for i, b in enumerate(bones)}
nodes = [{'name': n, 'translation': t} for n, p, t in bones]
for n, p, t in bones:
    if p: nodes[idx[p]].setdefault('children', []).append(idx[n])
world = {}
for n, p, t in bones:
    w = world[p] if p else [0, 0, 0]
    world[n] = [w[0] + t[0], w[1] + t[1], w[2] + t[2]]
skinNode = len(nodes); nodes.append({'name': 'strip', 'mesh': 0, 'skin': 0})
rootNode = len(nodes); nodes.append({'name': 'root', 'children': [idx['hips'], skinNode]})
# vertices: a strip from the head down the hair, two per joint
chain = ['head', 'hair1', 'hair2', 'hair3']
pos, joints, weights = [], [], []
for j, name in enumerate(chain):
    x, y, z = world[name]
    for dx in (-.05, .05):
        pos += [x + dx, y, z]; joints += [idx[name], 0, 0, 0]; weights += [1, 0, 0, 0]
n = len(pos) // 3
ind = []
for k in range(len(chain) - 1):
    a = 2 * k; ind += [a, a + 1, a + 2, a + 1, a + 3, a + 2]
morph = [0, 0, 0] * 2 + [0, .1, 0] * (n - 2)
ibm = []
for name, p, t in bones:
    x, y, z = world[name]
    ibm += [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -x, -y, -z, 1]
blobs = [struct.pack('<%df' % len(pos), *pos), struct.pack('<%dH' % len(joints), *joints), struct.pack('<%df' % len(weights), *weights),
         struct.pack('<%dI' % len(ind), *ind), struct.pack('<%df' % len(morph), *morph), struct.pack('<%df' % len(ibm), *ibm)]
bin_ = b''; views = []
for b in blobs:
    views.append({'buffer': 0, 'byteOffset': len(bin_), 'byteLength': len(b)}); bin_ += b + b'\0' * ((4 - len(b) % 4) % 4)
mn = [min(pos[i::3]) for i in range(3)]; mx = [max(pos[i::3]) for i in range(3)]
acc = [{'bufferView': 0, 'componentType': 5126, 'count': n, 'type': 'VEC3', 'min': mn, 'max': mx},
       {'bufferView': 1, 'componentType': 5123, 'count': n, 'type': 'VEC4'},
       {'bufferView': 2, 'componentType': 5126, 'count': n, 'type': 'VEC4'},
       {'bufferView': 3, 'componentType': 5125, 'count': len(ind), 'type': 'SCALAR'},
       {'bufferView': 4, 'componentType': 5126, 'count': n, 'type': 'VEC3'},
       {'bufferView': 5, 'componentType': 5126, 'count': len(bones), 'type': 'MAT4'}]
human = {k: {'node': idx[k]} for k in idx if not k.startswith('hair')}
gltf = {'asset': {'version': '2.0'}, 'extensionsUsed': ['VRMC_vrm', 'VRMC_springBone'], 'scene': 0, 'scenes': [{'nodes': [rootNode]}],
        'nodes': nodes, 'meshes': [{'primitives': [{'attributes': {'POSITION': 0, 'JOINTS_0': 1, 'WEIGHTS_0': 2}, 'indices': 3, 'targets': [{'POSITION': 4}]}]}],
        'skins': [{'joints': list(range(len(bones))), 'inverseBindMatrices': 5}], 'accessors': acc, 'bufferViews': views,
        'buffers': [{'byteLength': len(bin_)}],
        'extensions': {'VRMC_vrm': {'specVersion': '1.0', 'meta': {'name': 'Skinned', 'authors': ['tests'], 'licenseUrl': 'https://vrm.dev/licenses/1.0/'},
                                    'humanoid': {'humanBones': human},
                                    'expressions': {'preset': {'aa': {'morphTargetBinds': [{'node': skinNode, 'index': 0, 'weight': 1}]}, 'happy': {}}}},
                       'VRMC_springBone': {'specVersion': '1.0', 'colliders': [{'node': idx['head'], 'shape': {'sphere': {'offset': [0, 0, 0], 'radius': .05}}}],
                                           'colliderGroups': [{'colliders': [0]}],
                                           'springs': [{'joints': [{'node': idx['hair1'], 'stiffness': .5, 'gravityPower': 1, 'dragForce': .4, 'hitRadius': .02},
                                                                   {'node': idx['hair2'], 'stiffness': .5, 'gravityPower': 1, 'dragForce': .4, 'hitRadius': .02},
                                                                   {'node': idx['hair3']}], 'colliderGroups': [0]}]}}}
j = json.dumps(gltf).encode(); j += b' ' * ((4 - len(j) % 4) % 4)
out = struct.pack('<III', 0x46546C67, 2, 12 + 8 + len(j) + 8 + len(bin_)) + struct.pack('<II', len(j), 0x4E4F534A) + j + struct.pack('<II', len(bin_), 0x004E4942) + bin_
open(sys.argv[1], 'wb').write(out)
