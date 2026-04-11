import React, { useEffect } from 'react';
import { Modal, Form, Input, Typography, Space, Alert } from 'antd';
import { CloseCircleOutlined } from '@ant-design/icons';

const { Text } = Typography;

const RejectWithdrawalModal = ({ visible, record, onCancel, onConfirm, confirmLoading }) => {
    const [form] = Form.useForm();

    useEffect(() => {
        if (visible) {
            form.resetFields();
        }
    }, [visible, form]);

    const handleOk = () => {
        form.validateFields().then((values) => {
            onConfirm(record.id, values.adminNote);
        });
    };

    return (
        <Modal
            title={
                <Space>
                    <div style={{ padding: '6px', background: '#fee2e2', borderRadius: '50%', color: '#ef4444', display: 'flex' }}>
                        <CloseCircleOutlined style={{ fontSize: '18px' }} />
                    </div>
                    <span style={{ fontSize: '18px', fontWeight: 600, color: '#1E293B' }}>Từ chối yêu cầu</span>
                </Space>
            }
            open={visible}
            onCancel={onCancel}
            onOk={handleOk}
            confirmLoading={confirmLoading}
            okText="Xác nhận Từ chối & Hoàn tiền"
            okButtonProps={{ danger: true, style: { borderRadius: '6px', fontWeight: 500 } }}
            cancelButtonProps={{ style: { borderRadius: '6px' } }}
            width={480}
            centered
        >
            <Alert
                message="Hành động này sẽ hoàn lại tiền vào ví của cửa hàng!"
                description={
                    <span>
                        Số tiền <b>{Math.abs(record?.amount || 0).toLocaleString('vi-VN')} đ</b> sẽ được cộng ngược lại vào số dư ví của cửa hàng <b>{record?.storeName}</b>.
                    </span>
                }
                type="error"
                showIcon
                style={{ marginBottom: '24px', borderRadius: '8px' }}
            />

            <Form form={form} layout="vertical">
                <Form.Item
                    name="adminNote"
                    label={<Text strong>Lý do từ chối (Gửi cho Cửa hàng)</Text>}
                    rules={[
                        { required: true, message: 'Bắt buộc phải nhập lý do từ chối!' },
                        { min: 5, message: 'Vui lòng nhập lý do rõ ràng hơn (ít nhất 5 ký tự)!' }
                    ]}
                >
                    <Input.TextArea 
                        rows={4} 
                        placeholder="Ví dụ: Tài khoản ngân hàng sai lệch tên chủ tài khoản, vui lòng liên hệ CSKH..." 
                        maxLength={255}
                        showCount
                        style={{ borderRadius: '8px' }}
                    />
                </Form.Item>
            </Form>
        </Modal>
    );
};

export default RejectWithdrawalModal;