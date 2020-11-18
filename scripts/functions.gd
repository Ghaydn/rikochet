extends Node
#некоторые нужные функции, которых я не нашёл в годоте

#делает массив из векторов. Полезно, когда надо указать четыре направления.
func array4vect(in0: Vector2, in1: Vector2, in2: Vector2, in3: Vector2) -> PoolVector2Array:
	var arr: PoolVector2Array
	arr.append(in0)
	arr.append(in1)
	arr.append(in2)
	arr.append(in3)
	return arr

#делает массив четырёх векторов из восьми чисел
func array8x(in0: int, in1: int, in2: int, in3: int, in4: int, in5: int, in6: int, in7: int) -> PoolVector2Array:
	var arr: PoolVector2Array
	arr.append(Vector2(in0, in1))
	arr.append(Vector2(in2, in3))
	arr.append(Vector2(in4, in5))
	arr.append(Vector2(in6, in7))
	return arr

#делает массив из четырёх чисел
func array4x(in0: int, in1: int, in2: int, in3: int) -> PoolIntArray:
	var arr: PoolIntArray
	arr.append(in0)
	arr.append(in1)
	arr.append(in2)
	arr.append(in3)
	return arr

#смещает массив ВЛЕВО
func shift_array(arr, shift: int):
	var TMP = []
	var size = arr.size()
	for i in range(size):
		TMP.append(arr[(i + shift) % size])
	return TMP

func random(minimum: float, maximum: float) -> float:
	var base = randf() * (maximum - minimum)
	return (minimum + maximum) / 2 - randf() * base + randf() * base
