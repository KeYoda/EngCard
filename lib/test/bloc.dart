// import 'dart:async';
// import 'package:bloc/bloc.dart';
// import 'package:eng_card/data/untitled1.dart';

// class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
//   final FavoriteList favLists;

//   FavoriteBloc(this.favLists) : super(FavoriteInitial());

//   @override
//   Stream<FavoriteState> mapEventToState(FavoriteEvent event) async* {
//     if (event is DeleteFavoriteEvent) {
//       favLists.deleteFavorite(event.index);
//       yield FavoriteDeleted();
//     }
//   }
// }

// // Event
// abstract class FavoriteEvent {}

// class DeleteFavoriteEvent extends FavoriteEvent {
//   final int index;

//   DeleteFavoriteEvent(this.index);
// }

// // State
// abstract class FavoriteState {}

// class FavoriteInitial extends FavoriteState {}

// class FavoriteDeleted extends FavoriteState {}
