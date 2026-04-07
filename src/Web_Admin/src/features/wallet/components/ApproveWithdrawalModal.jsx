import React, { useState, useEffect } from 'react';
import { Modal, Form, Upload, message, Typography, Space, Alert } from 'antd';
import { LoadingOutlined, PlusOutlined, CheckCircleOutlined, CopyOutlined } from '@ant-design/icons';
import { uploadToCloudinary } from '../../../utils/cloudinaryApi';

const { Text } = Typography;

const ApproveWithdrawalModal = ({ visible, record, onCancel, onConfirm, confirmLoading }) => {
    const [form] = Form.useForm();
    const [imageUrl, setImageUrl] = useState('');
    const [uploading, setUploading] = useState(false);

    useEffect(() => {
        if (visible) {
            form.resetFields();
            setImageUrl('');
        }
    }, [visible, form]);

    const customUploadRequest = async (options) => {
        const { file, onSuccess, onError } = options;
        try {
            setUploading(true);
            const secureUrl = await uploadToCloudinary(file, 'WithdrawalReceipts');
            setImageUrl(secureUrl);
            form.setFieldsValue({ receiptImageUrl: secureUrl });
            onSuccess("ok");
            message.success('Tải biên lai lên thành công!');
        } catch (err) {
            onError(err);
            message.error(err.message || 'Lỗi khi tải ảnh!');
        } finally {
            setUploading(false);
        }
    };

    const handleOk = () => {
        form.validateFields().then(() => {
            onConfirm(record.id, imageUrl);
        }).catch(() => {
            message.warning('Vui lòng hoàn thiện thông tin bắt buộc!');
        });
    };

    return (
        <Modal
            title={
                <Space>
                    <div style={{ padding: '6px', background: '#d1fae5', borderRadius: '50%', color: '#10b981', display: 'flex' }}>
                        <CheckCircleOutlined style={{ fontSize: '18px' }} />
                    </div>
                    <span style={{ fontSize: '18px', fontWeight: 600, color: '#1E293B' }}>Xác nhận & Duyệt lệnh</span>
                </Space>
            }
            open={visible}
            onCancel={onCancel}
            onOk={handleOk}
            confirmLoading={confirmLoading || uploading}
            okText="Hoàn tất chuyển khoản"
            cancelText="Đóng"
            okButtonProps={{ 
                disabled: !imageUrl, 
                style: { backgroundColor: '#10b981', borderColor: '#10b981', borderRadius: '6px' } 
            }}
            cancelButtonProps={{ style: { borderRadius: '6px' } }}
            width={480}
            centered
        >
            <Alert
                message="Lưu ý"
                description="Bạn cần thực hiện chuyển khoản ngoài hệ thống (qua App Ngân hàng) theo đúng thông tin bên dưới, sau đó chụp lại biên lai và tải lên đây."
                type="info"
                showIcon
                style={{ marginBottom: '20px', borderRadius: '8px' }}
            />
            <div style={{ 
                backgroundColor: '#FAFAFA', 
                border: '1px solid #E2E8F0',
                padding: '20px', 
                borderRadius: '12px', 
                marginBottom: '24px',
                boxShadow: 'inset 0 2px 4px 0 rgb(0 0 0 / 0.02)'
            }}>
                <div style={{ textAlign: 'center', marginBottom: '16px' }}>
                    <Text type="secondary">Số tiền cần chuyển</Text>
                    <div style={{ color: '#0F172A', fontSize: '28px', fontWeight: 700 }}>
                        {Math.abs(record?.amount || 0).toLocaleString('vi-VN')} <span style={{ fontSize: '18px', color: '#64748B' }}>VNĐ</span>
                    </div>
                </div>
                
                <div style={{ borderTop: '1px dashed #CBD5E1', margin: '16px 0' }} />

                <Space direction="vertical" size="middle" style={{ width: '100%' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                        <Text type="secondary">Ngân hàng thụ hưởng:</Text>
                        <Text strong>{record?.bankName}</Text>
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                        <Text type="secondary">Chủ tài khoản:</Text>
                        <Text strong style={{ textTransform: 'uppercase' }}>{record?.bankAccountName || 'N/A'}</Text>
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <Text type="secondary">Số tài khoản:</Text>
                        <Space>
                            <Text strong style={{ fontSize: '16px', color: '#1890ff' }}>{record?.bankAccountNumber}</Text>
                            <Text copyable={{ text: record?.bankAccountNumber, icon: <CopyOutlined style={{ color: '#1890ff' }}/> }} />
                        </Space>
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                        <Text type="secondary">Nội dung (Gợi ý):</Text>
                        <Text strong>Thanh toan rut tien {record?.storeName}</Text>
                    </div>
                </Space>
            </div>

            <Form form={form} layout="vertical">
                <Form.Item
                    name="receiptImageUrl"
                    label={<Text strong>Biên lai chuyển khoản (Bắt buộc)</Text>}
                    rules={[{ required: true, message: 'Vui lòng tải lên ảnh chụp biên lai!' }]}
                >
                    <Upload
                        name="receipt"
                        listType="picture-card"
                        showUploadList={false}
                        customRequest={customUploadRequest}
                        beforeUpload={(file) => {
                            const isJpgOrPng = file.type === 'image/jpeg' || file.type === 'image/png' || file.type === 'image/webp';
                            if (!isJpgOrPng) message.error('Chỉ hỗ trợ JPG/PNG/WEBP!');
                            return isJpgOrPng;
                        }}
                    >
                        {imageUrl ? (
                            <img src={imageUrl} alt="receipt" style={{ width: '100%', height: '100%', objectFit: 'cover', borderRadius: '6px' }} />
                        ) : (
                            <div>
                                {uploading ? <LoadingOutlined /> : <PlusOutlined />}
                                <div style={{ marginTop: 8 }}>Tải ảnh lên</div>
                            </div>
                        )}
                    </Upload>
                </Form.Item>
            </Form>
        </Modal>
    );
};

export default ApproveWithdrawalModal;