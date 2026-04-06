import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/booking_bill_model.dart';

class PdfInvoiceHelper {
  static final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  static Future<Uint8List> generatePdfBytes(BookingBillModel bill) async {
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
        italic: fontItalic,
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(32), 
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      bill.storeName.toUpperCase(),
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('Địa chỉ: ${bill.storeAddress}', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800), textAlign: pw.TextAlign.center),
                    pw.Text('Hotline: ${bill.storePhone}', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800)),
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'HÓA ĐƠN THANH TOÁN',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 12),
                  ],
                ),
              ),

              pw.Divider(borderStyle: pw.BorderStyle.dashed, color: PdfColors.grey400),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Khách hàng: ${bill.customerName}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.SizedBox(height: 4),
                      pw.Text('Số điện thoại: ${bill.customerPhone}', style: const pw.TextStyle(fontSize: 11)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Mã hóa đơn: #${bill.bookingId}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.SizedBox(height: 4),
                      pw.Text('Ngày tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(bill.createdAt)}', style: const pw.TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),

              pw.TableHelper.fromTextArray(
                headers: ['Dịch vụ', 'Số lượng', 'Đơn giá', 'Thành tiền'],
                data: bill.services.map((item) => [
                  item.serviceName,
                  item.quantity.toString(),
                  formatCurrency.format(item.unitPrice),
                  formatCurrency.format(item.totalPrice),
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellStyle: const pw.TextStyle(fontSize: 11),
                cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
              ),

              pw.SizedBox(height: 16),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 220, 
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      _buildSummaryRow('Tổng cộng:', bill.subTotal),
                      if (bill.discountAmount > 0)
                        _buildSummaryRow('Giảm giá:', -bill.discountAmount, textColor: PdfColors.red600),
                      if (bill.depositAmount > 0)
                        _buildSummaryRow('Đã cọc (Online):', -bill.depositAmount, textColor: PdfColors.green700),
                      
                      pw.SizedBox(height: 8),
                      pw.Divider(color: PdfColors.grey400, thickness: 1),
                      pw.SizedBox(height: 8),

                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('CẦN TRẢ:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                              formatCurrency.format(bill.amountToPay), 
                              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.Spacer(), 
              pw.Divider(borderStyle: pw.BorderStyle.dashed, color: PdfColors.grey400),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('Cảm ơn Quý khách và hẹn gặp lại!', style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
                    pw.SizedBox(height: 4),
                    pw.Text('Phiếu thu có giá trị xuất hóa đơn trong ngày', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                  ]
                )
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  static pw.Widget _buildSummaryRow(String label, double value, {PdfColor textColor = PdfColors.black}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          pw.Text(
            formatCurrency.format(value), 
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textColor)
          ),
        ],
      ),
    );
  }
}