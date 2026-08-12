import 'package:flutter/material.dart';
import '../model/support_ticket_model.dart';
import '../repo/support_repo.dart';

enum SupportListStatus { idle, loading, loaded, empty, error }
enum CreateTicketStatus { idle, submitting, success, error }


class SupportViewModel extends ChangeNotifier {
  final SupportRepository _repo = SupportRepository();

  SupportListStatus _listStatus = SupportListStatus.idle;
  SupportListStatus get listStatus => _listStatus;
  bool get isListLoading => _listStatus == SupportListStatus.loading;

  String? _listErrorMessage;
  String? get listErrorMessage => _listErrorMessage;

  List<SupportTicketModel> _tickets = [];
  List<SupportTicketModel> get tickets => _tickets;

  Future<void> fetchMyTickets({bool silent = false}) async {
    // silent=true -> pull-to-refresh ke waqt skeleton dobara nahi dikhega
    if (!silent) _listStatus = SupportListStatus.loading;
    notifyListeners();

    final response = await _repo.getMyTickets();

    if (response.isCompleted && response.data != null) {
      _tickets = response.data!;
      _listStatus =
      _tickets.isEmpty ? SupportListStatus.empty : SupportListStatus.loaded;
    } else {
      _listErrorMessage = response.message;
      _listStatus = SupportListStatus.error;
    }
    notifyListeners();
  }

  // ---------------- CREATE STATE ----------------
  CreateTicketStatus _createStatus = CreateTicketStatus.idle;
  CreateTicketStatus get createStatus => _createStatus;
  bool get isSubmitting => _createStatus == CreateTicketStatus.submitting;

  String? _createErrorMessage;
  String? get createErrorMessage => _createErrorMessage;

  Future<bool> createTicket({
    required String title,
    required String description,
  }) async {
    _createStatus = CreateTicketStatus.submitting;
    _createErrorMessage = null;
    notifyListeners();

    final response = await _repo.createTicket(title: title, description: description);

    if (response.isCompleted && response.data != null) {
      _tickets = [response.data!, ..._tickets];
      if (_listStatus == SupportListStatus.empty) {
        _listStatus = SupportListStatus.loaded;
      }
      _createStatus = CreateTicketStatus.success;
      notifyListeners();
      return true;
    } else {
      _createErrorMessage = response.message;
      _createStatus = CreateTicketStatus.error;
      notifyListeners();
      return false;
    }
  }
}