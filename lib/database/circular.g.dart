// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circular.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CircularAdapter extends TypeAdapter<Circular> {
  @override
  final int typeId = 1;

  @override
  Circular read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Circular(
      title: fields[0] as String,
      content: fields[1] as String,
      imgUrl: fields[2] as String,
      author: fields[3] as String,
      id: fields[4] as String,
      files: (fields[5] as List)?.cast<dynamic>(),
      channels: (fields[6] as List)?.cast<dynamic>(),
      dept: (fields[7] as List)?.cast<dynamic>(),
      year: (fields[8] as List)?.cast<dynamic>(),
      division: (fields[9] as List)?.cast<dynamic>(),
      date: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Circular obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.imgUrl)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.files)
      ..writeByte(6)
      ..write(obj.channels)
      ..writeByte(7)
      ..write(obj.dept)
      ..writeByte(8)
      ..write(obj.year)
      ..writeByte(9)
      ..write(obj.division)
      ..writeByte(10)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircularAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
