import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import 'package:printing/printing.dart';
import '../models/booking_bill_model.dart';
import '../utils/pdf_invoice_helper.dart';

class BookingBillPreviewScreen extends StatelessWidget {
  final BookingBillModel bill;

  const BookingBillPreviewScreen({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: 'Xem trước hóa đơn',
      ),

      body: PdfPreview(
        build: (format) => PdfInvoiceHelper.generatePdfBytes(bill),
        allowPrinting: true,     
        allowSharing: true,     
        canChangePageFormat: false, 
        canChangeOrientation: false, 
        canDebug: false,      
        pdfFileName: 'HoaDon_Booking_${bill.bookingId}.pdf', 
      ),
    );
  }
}