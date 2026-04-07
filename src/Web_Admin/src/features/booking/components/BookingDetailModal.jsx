import React, { useState, useEffect } from 'react';
import { Modal, Descriptions, Typography, Space, Input, Button, message, Alert, Card, Divider } from 'antd'; 
import { bookingApi } from '../api/bookingApi';
import { BookingStatus } from '@/constants';
import BookingStatusTag from './BookingStatusTag';
import PaymentStatusTag from './PaymentStatusTag'; 

const { Text, Title } = Typography;

const BookingDetailModal = ({ isOpen, bookingId, onClose, onRefresh }) => {
  const [detail, setDetail] = useState(null);
  const [loading, setLoading] = useState(true);
  const [cancelReason, setCancelReason] = useState('');
  const [isCancelling, setIsCancelling] = useState(false);

  useEffect(() => {
    const fetchDetail = async () => {
      if (!bookingId || !isOpen) return;
      try {
        setLoading(true);
        const data = await bookingApi.getBookingDetail(bookingId);
        setDetail(data);
      } catch (error) {
        message.error("Không thể tải chi tiết lịch hẹn.");
        onClose();
      } finally {
        setLoading(false);
      }
    };
    fetchDetail();
  }, [bookingId, isOpen, onClose]);

  const handleCancelBooking = async () => {
    if (!cancelReason.trim()) {
      message.warning("Vui lòng nhập lý do hủy đơn!");
      return;
    }
    Modal.confirm({
      title: 'Xác nhận hủy đơn',
      content: 'Bạn có chắc chắn muốn hủy đơn này? Hành động này không thể hoàn tác.',
      okText: 'Hủy đơn',
      okType: 'danger',
      cancelText: 'Quay lại',
      onOk: async () => {
        try {
          setIsCancelling(true);
          await bookingApi.cancelBooking(bookingId, cancelReason);
          message.success("Đã hủy đơn thành công!");
          onRefresh(); 
          onClose();   
        } catch (error) {
          message.error("Có lỗi xảy ra khi hủy đơn.");
        } finally {
          setIsCancelling(false);
        }
      }
    });
  };

  const canCancel = detail?.status === BookingStatus.Pending || detail?.status === BookingStatus.Confirmed;

  return (
    <Modal
      title={<span style={{ fontSize: '18px' }}>Chi tiết Đơn <Text style={{ color: '#4318FF' }}>BK-{bookingId}</Text></span>}
      open={isOpen}
      onCancel={onClose}
      footer={null} 
      width={750}
      loading={loading}
      destroyOnHidden
    >
      {detail && (
        <Space orientation="vertical" size="large" style={{ width: '100%', display: 'flex', flexDirection: 'column' }}>
          
          <Descriptions bordered size="small" column={2} labelStyle={{ width: '140px', backgroundColor: '#f8fafc' }}>
            
            <Descriptions.Item label="Trạng thái đơn" span={1}>
              <BookingStatusTag status={detail.status} />
            </Descriptions.Item>
            <Descriptions.Item label="Thanh toán" span={1}>
              <PaymentStatusTag status={detail.paymentStatus} />
            </Descriptions.Item>
            
            <Descriptions.Item label="Khách hàng" span={2}><Text strong>{detail.customerName}</Text></Descriptions.Item>
            <Descriptions.Item label="Số điện thoại" span={2}>{detail.customerPhone}</Descriptions.Item>
            <Descriptions.Item label="Cửa hàng" span={2}><Text strong style={{ color: '#0958d9' }}>{detail.storeName}</Text></Descriptions.Item>
            <Descriptions.Item label="Ghi chú" span={2}>{detail.customerNote || <Text type="secondary" italic>Không có</Text>}</Descriptions.Item>
          </Descriptions>

          <Card size="small" style={{ backgroundColor: '#f1f5f9', borderColor: '#e2e8f0' }}>
            <Title level={5} style={{ margin: '0 0 12px 0', color: '#1E293B' }}>Chi tiết thanh toán</Title>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <Text>Tổng tiền dịch vụ:</Text>
                <Text>{detail.totalPrice?.toLocaleString()} đ</Text>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <Text>Giảm giá Voucher:</Text>
                <Text type="danger">- {detail.discountAmount?.toLocaleString()} đ</Text>
              </div>
              <Divider style={{ margin: '4px 0' }} />
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <Text strong>Thành tiền (Final Price):</Text>
                <Text strong>{detail.finalPrice?.toLocaleString()} đ</Text>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <Text>Đã cọc Online ({detail.paymentMethod || 'N/A'}):</Text>
                <Text type="success">- {detail.depositAmount?.toLocaleString()} đ</Text>
              </div>
              <Divider style={{ margin: '4px 0' }} />
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <Text strong style={{ fontSize: '16px', color: '#1E293B' }}>Cần thu tại quầy:</Text>
                <Text strong style={{ fontSize: '18px', color: '#ef4444' }}>{detail.remainingAmount?.toLocaleString()} đ</Text>
              </div>
            </div>
          </Card>

          {detail.status === BookingStatus.Cancelled && detail.cancelReason && (
            <Alert title="Đơn đã bị hủy" description={`Lý do: ${detail.cancelReason}`} type="error" showIcon />
          )}

          <div>
            <Title level={5} style={{ marginBottom: '12px' }}>Dịch vụ đã chọn</Title>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {detail.services?.map(svc => (
                <Card size="small" key={svc.bookingDetailId} style={{ backgroundColor: '#ffffff' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                      <Text strong>{svc.serviceName}</Text><br />
                      <Text type="secondary" style={{ fontSize: '13px' }}>
                        Thợ: {svc.staffName || 'Chưa chọn'} | Khung giờ: {svc.startTime} - {svc.endTime}
                      </Text>
                    </div>
                    <Text strong type="success" style={{ fontSize: '15px' }}>{svc.price?.toLocaleString()} đ</Text>
                  </div>
                </Card>
              ))}
            </div>
          </div>

          {canCancel && (
            <Card size="small" style={{ backgroundColor: '#fff7e6', borderColor: '#ffd591' }}>
              <Space orientation="vertical" style={{ width: '100%', display: 'flex', flexDirection: 'column' }}>
                <Text strong type="warning">Hủy đơn khẩn cấp (Quyền Admin)</Text>
                <Space.Compact style={{ width: '100%' }}>
                  <Input 
                    placeholder="Nhập lý do hủy bắt buộc..." 
                    value={cancelReason}
                    onChange={(e) => setCancelReason(e.target.value)}
                  />
                  <Button danger type="primary" onClick={handleCancelBooking} loading={isCancelling}>
                    Xác nhận hủy
                  </Button>
                </Space.Compact>
              </Space>
            </Card>
          )}

          <div style={{ textAlign: 'right' }}>
            <Button onClick={onClose} size="large">Đóng lại</Button>
          </div>
        </Space>
      )}
    </Modal>
  );
};

export default BookingDetailModal;